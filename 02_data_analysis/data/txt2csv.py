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

if __name__ == "__main__":
    # Example usage
    txt_file_path = "data/opensignals_98D351FE8835_2026-01-03_21-04-43.txt"
    txt_to_csv(txt_file_path)