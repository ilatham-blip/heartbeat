#  Signal Processing Pipeline

This project is a signal processing pipeline for Group Prometheus, under supervision of Prof Richard Kitney for the Biomedical Engineering Group Project 2025-26. The pipeline is built off of the e2epyppg project: https://github.com/HealthSciTech/E2E-PPG and extracts HRV parameters from PPG signals. This project adapts e2epyppg for use with the PLUX HEARTBIT sensor.

@inproceedings{feli2023end,
  title={End-to-End PPG Processing Pipeline for Wearables: From Quality Assessment and Motion Artifacts Removal to HR/HRV Feature Extraction},
  author={Feli, Mohammad and Kazemi, Kianoosh and Azimi, Iman and Wang, Yuning and Rahmani, Amir and Liljeberg, Pasi},
  booktitle={2023 IEEE International Conference on Bioinformatics and Biomedicine (BIBM)},
  year={2023},
  organization={IEEE}
}

***NOTE:*** This was created on MacOS and has not yet been tested on windows so may not work.


## Prerequisites and Setup
This project uses Python 3.10

### 1. Clone the repository:
In the terminal:

    git clone https://github.com/oscar-graham/Prometheus_HRV_Signal_Processing.git
    cd Prometheus_HRV_Signal_Processing

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
