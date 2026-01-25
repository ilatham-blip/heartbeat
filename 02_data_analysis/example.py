
## STILL IN DEVELOPMENT NOT CURRENTLY WORKING


import os
import warnings
from e2e_ppg_pipeline import e2e_hrv_extraction
from retrieve import load_ppg_into_pipeline
warnings.filterwarnings("ignore")


# Import a sample data
from retrieve import load_ppg_into_pipeline

measurement, ppg_df = load_ppg_into_pipeline("bde02a90-6b1d-4342-b5f7-d0fe93b0a1fd")


# Set the window length for HR and HRV extraction in seconds
window_length_sec = 60

# Extract HRV parameters from the input PPG signal
hrv_data = e2e_hrv_extraction(
    input_sig=ppg_df,
    sampling_rate=100,
    window_length_sec=window_length_sec,
    peak_detection_method='kazemi')

if hrv_data is not None:
    print(hrv_data)

    # # Output file name
    # output_file_name = "_".join(['HRV_', file_name])
    
    # # Save HRV data to a CSV file
    # hrv_data.to_csv(os.path.join('data', output_file_name), index=False)