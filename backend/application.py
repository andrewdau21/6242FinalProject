import sys
import pandas as pd
from sklearn import neural_network
import file_helper as FileHelper
import collections
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.neural_network import MLPClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier

predictors = ['b_count', 's_count', 'on_1b', 'on_2b', 'on_3b', 'outs', 'prev_pitch_class']
response = ['pitch_class']

_, firstName, lastName = sys.argv

#Bring in the names
player = FileHelper.load_players((firstName, lastName))

#Bring in the at bats for a pitcher
atbats = FileHelper.load_atbats(player.loc[0].at['id'])

#Bring in the pitches for the at basts for a pitcher
players_pitches = FileHelper.load_pitches(atbats['ab_id'].tolist())

#Split into train and test
predict_train, predict_test, response_train, response_test = train_test_split(players_pitches[predictors], players_pitches[response], test_size=0.2)

#Show the count of pitches for each pitch_class
# print(collections.Counter(response_train['pitch_class']))

#Train model(s) [Log Regression, Neural Network, Decision Tree, Random Forest]
log_regression = LogisticRegression(multi_class='multinomial').fit(predict_train, response_train.values.flatten())

neur_net = MLPClassifier().fit(predict_train, response_train.values.flatten())

decision_tree = DecisionTreeClassifier().fit(predict_train, response_train.values.flatten())

random_forest = RandomForestClassifier().fit(predict_train, response_train.values.flatten())

#Test model(s)


#Compare model(s)
log_regression_score = log_regression.score(predict_test, response_test)
print('log_regression score: ', log_regression_score)
neur_net_score = neur_net.score(predict_test, response_test)
print('neur_net score:', neur_net_score)
decision_tree_score = decision_tree.score(predict_test, response_test)
print('decision_tree:', decision_tree_score)
random_forest_score = random_forest.score(predict_test, response_test)
print('random_forest:', random_forest_score)

#Build real model
model_values = [log_regression_score, neur_net_score, decision_tree_score, random_forest_score]
best_model_value = max(model_values)
if (best_model_value == log_regression_score):
    model_type = "Logistic Regression"
    model = LogisticRegression(multi_class='multinomial').fit(players_pitches[predictors], players_pitches[response].values.flatten())
elif (best_model_value == neur_net_score):
    model_type = "Neural Network"
    model = MLPClassifier().fit(players_pitches[predictors], players_pitches[response].values.flatten())
elif (best_model_value == decision_tree_score):
    model_type = "Decision Tree"
    model = DecisionTreeClassifier().fit(players_pitches[predictors], players_pitches[response].values.flatten())
elif (best_model_value == random_forest_score):
    model_type = "Random Forest"
    model = RandomForestClassifier().fit(players_pitches[predictors], players_pitches[response].values.flatten())

#Build classification output [real output dataset]
all_possible_pitches = pd.DataFrame(columns=predictors)
for balls in range(0,4):
    for strikes in range(0,3):
        for outs in range(0,3):
            for on_1b in (True, False):
                for on_2b in (True, False):
                    for on_3b in (True, False):
                        for prev_pitch_class in (0, 1, 2, 3):
                            new_row = {"b_count":balls, "s_count":strikes, "outs":outs, "on_1b":on_1b, \
                                "on_2b":on_2b, "on_3b":on_3b, "prev_pitch_class":prev_pitch_class, "model": model_type}
                            all_possible_pitches = all_possible_pitches.append(new_row, ignore_index=True)
                            
probabilities = model.predict_proba(all_possible_pitches)
probabilities_df = pd.DataFrame(probabilities, columns=['fastball', 'offspeed','breaking'])
final_df = pd.concat([all_possible_pitches, probabilities_df], axis=1)

FileHelper.write_to_file((firstName, lastName), final_df)