import csv
import numpy as np
import pandas as pd
from e2epyppg.utils import get_data



def csv2df(file_name, channels=None):
    """
    Load PPG data from a CSV file and return it as a pandas DataFrame.

    Parameters:
    file_name (str): Path to the CSV file.
    channels (list, optional): List of channel indices to extract. If None, all channels are returned.

    Returns:
    pd.DataFrame: Pandas DataFrame containing the specified channels of the PPG signal.
    """
    with open(file_name, 'r') as f:
        raw_data = pd.read_csv(f)
        if channels is not None:
            data = raw_data[channels]
        else:
            data = raw_data
        return data
    

import pandas as pd
import os

def txt_to_csv(txt_path):
    """
    Convert OpenSignals TXT file to CSV format.
    
    Args:
        txt_path: Path to the input .txt file
    
    Returns:
        Path to the generated CSV file
    """
    if not os.path.exists(txt_path):
        raise FileNotFoundError(f"File not found: {txt_path}")
    
    # Read text file
    df = pd.read_csv(
        txt_path,
        sep="\t",
        comment="#",
        header=None
    )
    
    # Drop empty columns (from trailing tabs)
    df = df.dropna(axis=1, how="all")
    
    # Assign column names safely
    df.columns = [
        "nSeq", "I1", "I2", "O1", "O2",
        "A1", "A2", "A3", "A4", "A5", "A6"
    ]
    
    # Get the directory where this script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Get just the filename from the original txt file
    original_filename = os.path.basename(txt_path)
    csv_filename = os.path.splitext(original_filename)[0] + ".csv"
    
    # Build output CSV path in the script's directory
    csv_path = os.path.join(script_dir, csv_filename)
    
    # Save CSV
    df.to_csv(csv_path, index=False)
    print(f"CSV exported to: {csv_path}")
    
    return csv_path

def csv2parquet(file_name, channels=None):
    with open(file_name, 'r') as f:
        raw_data = pd.read_csv(f)
        if channels is not None:
            data = raw_data[channels]
        else:
            data = raw_data
    
    # Get the directory where this script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Get just the filename from the original txt file
    original_filename = os.path.basename(file_name)
    parquet_filename = os.path.splitext(original_filename)[0] + ".parquet"
    
    # Build output CSV path in the script's directory
    parquet_path = os.path.join(script_dir, parquet_filename)

    data.to_parquet(parquet_path, index=False)
    return parquet_path


    

if __name__ == "__main__":
    # Example usage
    file_name = "data/opensignals_98D351FE8835_2025-12-21_20-12-02.csv"
    data = csv2df(file_name, ['A1', 'A2'])
    print(data.head(20))
    