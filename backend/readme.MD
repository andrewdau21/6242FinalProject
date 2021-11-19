# Python project for data analysis

## Data
The data for this project is too big to be put in GitHub.  It can be found here: https://www.kaggle.com/pschale/pitch-type-prediction/data

Download each file (atbats.csv, pitches.csv, layer_names.csv) and place the in the 'data' folder

## Code
The application.py program does the bulk of the heavy lifting.  This is the file you want to run.

The file_helper.py does the reading of the files

## How to Run
Assuming you have python installed on your local PC and the data setup correctly, ensure you are in the 'backend' directory and run the following command:
~~ python application.py <firstName> <lastName>~~
You can use run_multiple.py to run many pitchers.  Run the following: python run_multiple.py <start_index> <end_index>

This will generate a file in the 'output' folder titled: <firstName>_<lastName>_pitch_probabilities.csv

This will also generate (or append to) a file in the 'output' folder titled "results.txt" with information about what model was chosen, what parameters were chosen for the model and what the model accuracy scores were

