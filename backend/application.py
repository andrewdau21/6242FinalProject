import pandas as pd
import file_helper as FileHelper

#Source for application

#Bring in the names
player_jon_lester = FileHelper.load_players(("Jon", "Lester"))

#Bring in the at bats for a pitcher
jon_lester_atbats = FileHelper.load_atbats(player_jon_lester.loc[0].at['id'])

#Bring in the pitches for the at basts for a pitcher
jon_lester_pitches = FileHelper.load_pitches(jon_lester_atbats['ab_id'].tolist())

#Split into train and test


#Train model(s)

#Test model(s)

#Compare model(s)

#Build real model

#Build classification output [real output dataset]