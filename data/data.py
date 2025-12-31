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
    

if __name__ == "__main__":
    # Example usage
    file_name = "data/opensignals_98D351FE8835_2025-12-21_20-12-02.csv"
    data = csv2df(file_name, ['A1', 'A2'])
    print(data.head(20))
    