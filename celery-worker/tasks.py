from celery_app import celery_app
from supabase import create_client
import os
import pandas as pd
from io import BytesIO
from dotenv import load_dotenv
import numpy as np

# Your e2epyppg imports
from e2epyppg.ppg_sqa import sqa
from e2epyppg.ppg_reconstruction import reconstruction
from e2epyppg.ppg_clean_extraction import clean_seg_extraction
from e2epyppg.ppg_peak_detection import peak_detection
from e2epyppg.ppg_hrv_extraction import hrv_extraction



# Load Environment Variables
load_dotenv()
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_SERVICE_KEY")

if not url or not key:
    print("Error: Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in .env file")
    exit()

# Create Supabase client
supabase = create_client(url, key)
print(f"✅ Connected to: {url}")




#Access Supabase and the required patient information
def get_measurement_by_id(measurement_id: str):
    """
    Retrieve measurement metadata from the database
    
    Args:
        measurement_id: The ID of the measurement to retrieve
        
    Returns:
        dict: Measurement data including raw_file_path
    """
    print(f"\n--- RETRIEVING MEASUREMENT {measurement_id} ---")
    
    try:
        response = supabase.table('measurements').select('*').eq('measurement_id', measurement_id).execute()
        
        if not response.data or len(response.data) == 0:
            print(f"❌ No measurement found with ID: {measurement_id}")
            return None
        
        measurement = response.data[0]
        print(f"✅ Found measurement:")
        print(f"   User ID: {measurement.get('user_id')}")
        print(f"   Recorded at: {measurement.get('recorded_at')}")
        print(f"   Heart Rate: {measurement.get('heart_rate')}")
        print(f"   HRV Score: {measurement.get('hrv_score')}")
        print(f"   Raw File Path: {measurement.get('raw_file_path')}")
        
        return measurement
        
    except Exception as e:
        print(f"❌ Error retrieving measurement: {e}")
        return None

def download_ppg_file(raw_file_path: str , bucket_name: str = 'raw_uploads'):
    """
    Download PPG file from Supabase Storage bucket
    
    Args:
        raw_file_path: Path to the file in the bucket (e.g., 'user123/recording_20240125.csv')
        bucket_name: Name of the Supabase storage bucket
        
    Returns:
        pandas.DataFrame: The PPG signal data
    """
    print(f"\n--- DOWNLOADING FILE FROM BUCKET ---")
    print(f"   Bucket: {bucket_name}")
    print(f"   Path: {raw_file_path}")
    
    try:
        # Download file from Supabase Storage
        response = supabase.storage.from_(bucket_name).download(raw_file_path)
        
        # Convert bytes to pandas DataFrame
        # Assuming the file is a parquet
        
        df = pd.read_parquet(BytesIO(response))
        
        print(f"✅ File downloaded successfully!")
        print(f"   Shape: {df.shape}")
        print(f"   Columns: {df.columns.tolist()}")
        print(f"\n   Preview:")
        print(df.head())
        
        return df
        
    except Exception as e:
        print(f"❌ Error downloading file: {e}")
        print(f"   Make sure the bucket '{bucket_name}' exists and the file path is correct")
        return None

def load_ppg_into_pipeline(measurement_id: str, bucket_name: str = 'raw_uploads'):
    """
    Complete workflow: Retrieve measurement metadata, download file, and load into pipeline
    
    Args:
        measurement_id: The measurement ID to process
        bucket_name: Name of the Supabase storage bucket
        
    Returns:
        tuple: (measurement_metadata, ppg_dataframe)
    """
    print("\n" + "="*60)
    print(f"LOADING PPG DATA FOR MEASUREMENT: {measurement_id}")
    print("="*60)
    
    # Step 1: Get measurement metadata from database
    measurement = get_measurement_by_id(measurement_id)
    if not measurement:
        return None, None
    
    # Step 2: Extract file path
    raw_file_path = measurement.get('raw_file_path')
    if not raw_file_path:
        print("❌ No raw_file_path found in measurement record")
        return measurement, None
    
    # Step 3: Download and load PPG file
    ppg_df = download_ppg_file(raw_file_path, bucket_name)
    if ppg_df is None:
        return measurement, None
    
    print("\n" + "="*60)
    print("✅ READY FOR PROCESSING")
    print("="*60)
    
    return measurement, ppg_df





@celery_app.task(name='process_ppg_measurement')
def ppg_processing(measurement_id):
    """
    Celery task to process PPG measurement with e2epyppg
    
    Args:
        measurement_id: UUID of the measurement to process
    """

    measurement, ppg_df = load_ppg_into_pipeline(measurement_id)

    data = ppg_df

    A1 = data['A1'].values

    input_sig = A1
    sampling_rate = 100
    window_length_sec = 120

    # Set this parameter True if the signal has not been filtered:
    filter_signal = True

    # Call the PPG signal quality assessment function
    clean_indices, noisy_indices = sqa(input_sig, sampling_rate, filter_signal)

    # Call the PPG reconstruction function
    ppg_reconstructed, updated_clean_indices, updated_noisy_indices = reconstruction(input_sig, clean_indices, noisy_indices, sampling_rate, filter_signal)

    # Set the window length for HR and HRV extraction in terms of samples
    window_length = window_length_sec*sampling_rate

    # Call the clean segment extraction function
    clean_segments = clean_seg_extraction(ppg_reconstructed, updated_noisy_indices, window_length)

    # Set the peak detection method (optional)
    peak_detection_method = 'heartpy'

    # Call the peak detection function
    peaks = peak_detection(clean_segments, sampling_rate, peak_detection_method)

    flat_peaks = np.concatenate(peaks)

    df_peaks = pd.DataFrame({'Peak Sample': flat_peaks})


    # Upload peaks to storage
    peaks_filename = f"{measurement_id}_peaks.parquet"
    peaks_buffer = BytesIO()
    df_peaks.to_parquet(peaks_buffer, index=False)
    peaks_buffer.seek(0)

    supabase.storage.from_('peak_indices').upload(
        path=peaks_filename,
        file=peaks_buffer.getvalue(),
        file_options={"content-type": "application/octet-stream"}
        )



    # Call the HR and HRV feature extraction function
    if not peaks:
        print("No peaks detected — skipping HRV extraction.")
        hrv_data = pd.DataFrame()  # or None as you prefer
    else:
        hrv_data = hrv_extraction(clean_segments=clean_segments, peaks=peaks, sampling_rate=sampling_rate, window_length=window_length)
        print("HRV columns available:", hrv_data.columns.tolist())
        print("HRV data shape:", hrv_data.shape)
        hrv_data = hrv_data[['HR', 'HRV_MeanNN', 'HRV_RMSSD', 'HRV_LF', 'HRV_HF', 'HRV_LFHF']]
        print(hrv_data)


        supabase.table('measurements').update({
            'heart_rate': float(hrv_data['HR'][0]) if pd.notna(hrv_data['HR'][0]) else None,
            'mean_nn': float(hrv_data['HRV_MeanNN'][0]) if pd.notna(hrv_data['HRV_MeanNN'][0]) else None,
            'rmssd': float(hrv_data['HRV_RMSSD'][0]) if pd.notna(hrv_data['HRV_RMSSD'][0]) else None,
            'lf': float(hrv_data['HRV_LF'][0]) if pd.notna(hrv_data['HRV_LF'][0]) else None,
            'hf': float(hrv_data['HRV_HF'][0]) if pd.notna(hrv_data['HRV_HF'][0]) else None,
            'lf_hf_ratio': float(hrv_data['HRV_LFHF'][0]) if pd.notna(hrv_data['HRV_LFHF'][0]) else None,
            'peaks_file_path': peaks_filename,
        }).eq('measurement_id', measurement_id).execute()  


if __name__ == "__main__":
    ppg_processing("f20c688a-4231-45f3-b703-bd00b1d73d27")




  

