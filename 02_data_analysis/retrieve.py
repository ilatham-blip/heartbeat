# Script to retrieve PPG signal from Supabase and load into processing pipeline
import os
import pandas as pd
from dotenv import load_dotenv
from supabase import create_client, Client
from io import StringIO
from io import BytesIO
import tempfile

# Load environment variables
load_dotenv()
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_SERVICE_KEY")

if not url or not key:
    print("Error: Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in .env file")
    exit()

# Create Supabase client
supabase: Client = create_client(url, key)
print(f"✅ Connected to: {url}")


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


def get_measurements_by_user(user_id: str, limit: int = 10):
    """
    Retrieve all measurements for a specific user
    
    Args:
        user_id: The user ID to filter by
        limit: Maximum number of measurements to retrieve
        
    Returns:
        list: List of measurement records
    """
    print(f"\n--- RETRIEVING MEASUREMENTS FOR USER {user_id} ---")
    
    try:
        response = supabase.table('measurements').select('*').eq('user_id', user_id).limit(limit).execute()
        
        if not response.data or len(response.data) == 0:
            print(f"❌ No measurements found for user: {user_id}")
            return []
        
        print(f"✅ Found {len(response.data)} measurement(s)")
        for m in response.data:
            print(f"   - ID: {m.get('measurement_id')}, Recorded: {m.get('recorded_at')}")
        
        return response.data
        
    except Exception as e:
        print(f"❌ Error retrieving measurements: {e}")
        return []


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


def download_ppg_file_to_disk(raw_file_path: str, bucket_name: str = 'raw_uploads', output_dir: str = './data'):
    """
    Download PPG file from Supabase Storage and save to local disk
    
    Args:
        raw_file_path: Path to the file in the bucket
        bucket_name: Name of the Supabase storage bucket
        output_dir: Local directory to save the file
        
    Returns:
        str: Path to the downloaded file
    """
    print(f"\n--- DOWNLOADING FILE TO DISK ---")
    
    try:
        # Create output directory if it doesn't exist
        os.makedirs(output_dir, exist_ok=True)
        
        # Download file
        response = supabase.storage.from_(bucket_name).download(raw_file_path)
        
        # Save to disk
        filename = os.path.basename(raw_file_path)
        local_path = os.path.join(output_dir, filename)
        
        with open(local_path, 'wb') as f:
            f.write(response)
        
        print(f"✅ File saved to: {local_path}")
        return local_path
        
    except Exception as e:
        print(f"❌ Error downloading file: {e}")
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


def process_with_e2epyppg(ppg_df, measurement_metadata):
    """
    Process PPG signal with e2epyppg pipeline
    
    Args:
        ppg_df: DataFrame containing PPG signal
        measurement_metadata: Metadata from database
        
    Returns:
        dict: HRV metrics computed by e2epyppg
    """
    print("\n--- PROCESSING WITH E2EPYPPG ---")
    
    try:
        # TODO: Replace this with your actual e2epyppg pipeline call
        # Example (adjust based on your e2epyppg API):
        # from e2epyppg import analyze_ppg
        # hrv_metrics = analyze_ppg(ppg_df)
        
        # Placeholder for testing
        print("⚠️  e2epyppg processing not yet implemented")
        print("   Add your e2epyppg analysis code here")
        
        # Example return structure
        hrv_metrics = {
            'SDNN': None,
            'RMSSD': None,
            'pNN50': None,
            'LF': None,
            'HF': None,
            'LF_HF_ratio': None
        }
        
        return hrv_metrics
        
    except Exception as e:
        print(f"❌ Error processing with e2epyppg: {e}")
        return None


def update_hrv_metrics(measurement_id: str, hrv_metrics: dict):
    """
    Update the measurements table with computed HRV metrics
    
    Args:
        measurement_id: The measurement ID to update
        hrv_metrics: Dictionary of HRV metrics to store
    """
    print(f"\n--- UPDATING MEASUREMENT {measurement_id} WITH HRV METRICS ---")
    
    try:
        # Update the record with new HRV metrics
        # Adjust field names based on what e2epyppg returns
        update_data = {
            'hrv_score': hrv_metrics.get('SDNN'),  # or whatever your main HRV metric is
            # Add more fields as needed
        }
        
        response = supabase.table('measurements').update(update_data).eq('measurement_id', measurement_id).execute()
        
        print("✅ Metrics updated successfully!")
        
    except Exception as e:
        print(f"❌ Error updating metrics: {e}")


# Example usage and test functions
def example_workflow():
    """Example of complete workflow"""
    
    # Example 1: Load a specific measurement
    measurement_id = "your-measurement-id-here"
    measurement, ppg_df = load_ppg_into_pipeline(measurement_id)
    
    if ppg_df is not None:
        # Process with e2epyppg
        hrv_metrics = process_with_e2epyppg(ppg_df, measurement)
        
        # Update database with results
        if hrv_metrics:
            update_hrv_metrics(measurement_id, hrv_metrics)
    
    # Example 2: Get all measurements for a user
    user_id = "your-user-id-here"
    measurements = get_measurements_by_user(user_id)
    
    # Process each measurement
    for m in measurements:
        measurement_id = m.get('measurement_id')
        measurement, ppg_df = load_ppg_into_pipeline(measurement_id)
        # ... continue processing


if __name__ == "__main__":
    # Test: List all measurements (first 5)
    print("\n--- LISTING ALL MEASUREMENTS ---")
    try:
        response = supabase.table('measurements').select('*').limit(5).execute()
        print(f"Found {len(response.data)} measurement(s):")
        for m in response.data:
            print(f"  - ID: {m.get('measurement_id')}, User: {m.get('user_id')}, File: {m.get('raw_file_path')}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Uncomment and modify to test with actual data:
    # measurement_id = "your-actual-measurement-id"
    # measurement, ppg_df = load_ppg_into_pipeline(measurement_id)