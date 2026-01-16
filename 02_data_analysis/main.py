from e2epyppg.utils import get_data
from e2epyppg.ppg_sqa import sqa
from e2epyppg.ppg_reconstruction import reconstruction
from e2epyppg.ppg_clean_extraction import clean_seg_extraction
from e2epyppg.ppg_peak_detection import peak_detection
from e2epyppg.ppg_hrv_extraction import hrv_extraction
from data.data import csv2df
from data.txt2csv import txt_to_csv
import numpy as np
import pandas as pd
import time


time_start = time.time()
# Provide your PPG signal and sampling rate (you can use your own signal in format `np.ndarray`)
file_name = "data/opensignals_98D351FE8835_2026-01-03_21-00-20.csv" # Change this to your file path
if file_name.endswith('.txt'):
    file_name = txt_to_csv(file_name)  # Convert to CSV first

data = csv2df(file_name)
A1 = data['A1'].values

input_sig = A1
sampling_rate = 100
window_length_sec = 60

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

print("HR and HRV parameters:")
print(hrv_data)
hrv_data.to_csv("hrv_output.csv", index=False)
time_end = time.time()
print("Total processing time (seconds):", time_end - time_start)