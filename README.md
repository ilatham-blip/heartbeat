#  Signal Processing Pipeline

This project is a signal processing pipeline for Group Prometheus, under supervision of Prof Richard Kitney for the Biomedical Engineering Group Project 2025-26. The pipeline extracts HRV parameters from PPG signals acquired using the PLUX HEARTBIT monitor.

***NOTE:*** This was created on MacOS and has not yet been tested on windows so may not work.


## Prerequisites and Setup
This project uses Python 3.10

### 1. Clone the repository:
In the terminal:

    git clone https://github.com/your-username/your-repo.git
    cd your-repo

Or clone manually via github.

### 2. Create Virtual Environment:

    python3.10 -m venv .venv
    source .venv/bin/activate # MacOS
    # .venv\Scripts\activate    # Windows
    

###  3. Install dependencies:

    pip install --upgrade pip
    pip install -r requirements.txt

### 4. Run the project

    source .venv/bin/activate
    python main.py


## Additional Information
Currently main.py is hardcoded to use one specific signal from the /data subdirectory (and also only analyses a single channel from that recording). 

To use a different signal, paste the signal into the /data subdirectory and change the file_name in main.py to point to the new file path for that signal.
