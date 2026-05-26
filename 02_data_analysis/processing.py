from e2epyppg.utils import get_data
from e2epyppg.ppg_sqa import sqa
from e2epyppg.ppg_reconstruction import reconstruction
from e2epyppg.ppg_clean_extraction import clean_seg_extraction
from e2epyppg.ppg_peak_detection import peak_detection
from e2epyppg.ppg_hrv_extraction import hrv_extraction
import os
import numpy as np
import pandas as pd
import time
from dotenv import load_dotenv
from supabase import create_client, Client
from retrieve import supabase
from retrieve import load_ppg_into_pipeline



load_dotenv()
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_SERVICE_KEY")

if not url or not key:
    print("Error: Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in .env file")
    exit()

# Create Supabase client
supabase: Client = create_client(url, key)
print(f"✅ Connected to: {url}")

def ppg_processing(measurement_id):



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
    peak_detection_method = 'kazemi'

    # Call the peak detection function
    peaks = peak_detection(clean_segments, sampling_rate, peak_detection_method)

    # Call the HR and HRV feature extraction function
    if not peaks:
        print("No peaks detected — skipping HRV extraction.")
        hrv_data = pd.DataFrame()  # or None as you prefer
    else:
        hrv_data = hrv_extraction(clean_segments=clean_segments, peaks=peaks, sampling_rate=sampling_rate, window_length=window_length)
        hrv_data = hrv_data[['HR', 'HRV_MeanNN', 'HRV_RMSSD', 'HRV_LF', 'HRV_HF', 'HRV_LFHF']]
        print(hrv_data)


        supabase.table('measurements').update({
            'heart_rate': float(hrv_data['HR'][0]) if pd.notna(hrv_data['HR'][0]) else None,
            'mean_nn': float(hrv_data['HRV_MeanNN'][0]) if pd.notna(hrv_data['HRV_MeanNN'][0]) else None,
            'rmssd': float(hrv_data['HRV_RMSSD'][0]) if pd.notna(hrv_data['HRV_RMSSD'][0]) else None,
            'lf': float(hrv_data['HRV_LF'][0]) if pd.notna(hrv_data['HRV_LF'][0]) else None,
            'hf': float(hrv_data['HRV_HF'][0]) if pd.notna(hrv_data['HRV_HF'][0]) else None,
            'lf_hf_ratio': float(hrv_data['HRV_LFHF'][0]) if pd.notna(hrv_data['HRV_LFHF'][0]) else None,
        }).eq('measurement_id', measurement_id).execute()   




# print("HR and HRV parameters:")
# print(hrv_data)
# # hrv_data.to_csv("hrv_output.csv", index=False)
# time_end = time.time()
# print("Total processing time (seconds):", time_end - time_start)