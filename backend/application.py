import sys
import pandas as pd
from sklearn import neural_network
import file_helper as FileHelper
import collections
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.linear_model import LogisticRegression
from sklearn.neural_network import MLPClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier

predictors = ['b_count', 's_count', 'on_1b', 'on_2b', 'on_3b', 'outs', 'prev_pitch_class']
response = ['pitch_class']

def run_all(firstName, lastName):
        
    #Bring in the names
    player = FileHelper.load_players((firstName, lastName))

    #Bring in the at bats for a pitcher
    atbats = FileHelper.load_atbats(player.iloc[0,0])

    #Bring in the pitches for the at basts for a pitcher
    players_pitches = FileHelper.load_pitches(atbats['ab_id'].tolist())

    #Split into train and test
    predict_train, predict_test, response_train, response_test = train_test_split(players_pitches[predictors], players_pitches[response], test_size=0.2)

    #Show the count of pitches for each pitch_class
    # print(collections.Counter(response_train['pitch_class']))

    model_comparison = {"pitcher": "{}_{}".format(firstName, lastName)}
    #Train model(s) [Log Regression, Neural Network, Decision Tree, Random Forest] & Test Model
    log_regression = LogisticRegression(multi_class='multinomial').fit(predict_train, response_train.values.flatten())
    lr_gscv = GridSearchCV(log_regression, param_grid = {'penalty': ['l2', 'none']}, n_jobs = -1)
    lr_model = lr_gscv.estimator
    lr_score = lr_model.score(predict_test, response_test)
    lr_comparison = {"score":lr_score, "parameter(s)": "penalty={}".format(lr_model.get_params()['penalty'])}
    model_comparison.update({"log_regression":lr_comparison})

    neur_net = MLPClassifier().fit(predict_train, response_train.values.flatten())
    nn_params = {'activation': ['identity', 'logistic', 'tanh', 'relu'], 'solver': ['lbfgs', 'sgd', 'adam'], 'hidden_layer_sizes': [(100), (150,100), (150,100,50)]}
    nn_gscv = GridSearchCV(neur_net, param_grid = nn_params, n_jobs=-1)
    nn_model = nn_gscv.estimator
    nn_score = nn_model.score(predict_test, response_test)
    nn_comparison = {"score":nn_score, "parameter(s)":"activation={}, solver={}, hidden layer sizes={}".format(nn_model.get_params()['activation'],nn_model.get_params()['solver'],nn_model.get_params()['hidden_layer_sizes'])}
    model_comparison.update({"neural_network":nn_comparison})

    decision_tree = DecisionTreeClassifier().fit(predict_train, response_train.values.flatten())
    dt_params = {'criterion': ['entropy', 'gini'], 'splitter':['best','random']}
    dt_gscv = GridSearchCV(decision_tree, param_grid=dt_params, n_jobs=-1)
    dt_model = dt_gscv.estimator
    dt_score = dt_model.score(predict_test, response_test)
    dt_comparison = {"score":dt_score, "parameter(s)":"criterion={}, splitter={}".format(dt_model.get_params()['criterion'],dt_model.get_params()['splitter'])}
    model_comparison.update({"decision_tree": dt_comparison})

    random_forest = RandomForestClassifier().fit(predict_train, response_train.values.flatten())
    rf_params = {'criterion':['gini', 'entropy'], 'n_estimators': [10, 100, 500]}
    rf_gscv = GridSearchCV(random_forest, param_grid=rf_params, n_jobs=-1)
    rf_model = rf_gscv.estimator
    rf_score = rf_model.score(predict_test, response_test)
    rf_comparison = {"score":rf_score, "parameter(s)": "criterion={}, n_estimators={}".format(rf_model.get_params()['criterion'], rf_model.get_params()['n_estimators'])}
    model_comparison.update({"random_forest": rf_comparison})


    #Compare & Build real model
    model_values = [lr_score , nn_score, dt_score, rf_score]
    best_model_value = max(model_values)
    if (best_model_value == lr_score):
        model_type = "Logistic Regression"
        model = lr_model.fit(players_pitches[predictors], players_pitches[response].values.flatten())
    elif (best_model_value == nn_score):
        model_type = "Neural Network"
        model = nn_model.fit(players_pitches[predictors], players_pitches[response].values.flatten())
    elif (best_model_value == dt_score):
        model_type = "Decision Tree"
        model = dt_model.fit(players_pitches[predictors], players_pitches[response].values.flatten())
    elif (best_model_value == rf_score):
        model_type = "Random Forest"
        model = rf_model.fit(players_pitches[predictors], players_pitches[response].values.flatten())
    model_comparison.update({"best_model":model_type})

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
                                    "on_2b":on_2b, "on_3b":on_3b, "prev_pitch_class":prev_pitch_class}
                                all_possible_pitches = all_possible_pitches.append(new_row, ignore_index=True)
                                
    probabilities = model.predict_proba(all_possible_pitches)
    probabilities_df = pd.DataFrame(probabilities, columns=['fastball', 'offspeed','breaking'])
    final_df = pd.concat([all_possible_pitches, probabilities_df], axis=1)
    final_df['model'] = model_type

    FileHelper.write_to_file((firstName, lastName), final_df)
    FileHelper.write_model_compare_results(model_comparison)


# _, firstName, lastName = sys.argv
# print('...gathering data for {} {}'.format(firstName, lastName))
# run_all(firstName, lastName)