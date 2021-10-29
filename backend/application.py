import pandas as pd
import file_helper as FileHelper
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression

predictors = ['b_count', 's_count', 'on_1b', 'on_2b', 'on_3b', 'outs', 'prev_pitch_class']
response = ['pitch_class']

#Bring in the names
player_jon_lester = FileHelper.load_players(("Jon", "Lester"))

#Bring in the at bats for a pitcher
jon_lester_atbats = FileHelper.load_atbats(player_jon_lester.loc[0].at['id'])

#Bring in the pitches for the at basts for a pitcher
jon_lester_pitches = FileHelper.load_pitches(jon_lester_atbats['ab_id'].tolist())

#Split into train and test
predict_train, predict_test, response_train, response_test = train_test_split(jon_lester_pitches[predictors], jon_lester_pitches[response], test_size=0.2)

#Train model(s) [Log Regression, Neural Network, Decision Tree, Random Forest]
log_regression = LogisticRegression(multi_class='multinomial').fit(predict_train, response_train.values.flatten())
print(log_regression)

#Test model(s)

#Compare model(s)

#Build real model

#Build classification output [real output dataset]