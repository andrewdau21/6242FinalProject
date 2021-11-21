import file_helper as FileHelper
import application as Application
import pandas as pd
import sys
import os

_, start, end = sys.argv

players = FileHelper.load_all_players().iloc[int(start):int(end),1:3]

for index in range(len(players)):
    fName = players.iloc[index, 0]
    lName = players.iloc[index, 1]
    print('Running {} of {}. Pitcher: {} {}'.format(index+int(start), end, fName, lName))
    Application.run_all(fName, lName)
