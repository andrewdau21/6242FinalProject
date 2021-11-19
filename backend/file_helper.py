from numpy import nan
import pandas as pd
import os
valid_pitches = ['CH', 'CU', 'KC', 'KN', 'SC', 'SL','FA', 'FC', 'FF', 'FS', 'FT', 'SI']
fastballs = ['FC', 'FF', 'FS', 'FT', 'SI','FA']
offspeeds = ['CH', 'KN']
breakings = ['CU', 'KC', 'SC', 'SL']
columns_of_concern = ['ab_id', 'pitch_num', 'b_count', 's_count', 'on_1b', 'on_2b', 'on_3b', 'outs', 'pitch_class', 'prev_pitch_class']

def load_players(name=('', '')):
    players = pd.read_csv('./data/player_names.csv')
    if ((name != ('',''))):
        player = players.loc[(players['first_name'] == name[0]) & (players['last_name'] == name[1])]
    return player


def load_atbats(pitcher_id = ''):
    atbats = pd.read_csv('./data/atbats.csv')
    atbats = atbats.reindex(sorted(atbats), axis=1)
    if (pitcher_id != ''):
        atbats = atbats.loc[(atbats['pitcher_id'] == pitcher_id)]
    return atbats

def pitch_class(pitch_type):
    if (pitch_type in fastballs):
        return 1
    elif (pitch_type in offspeeds):
        return 2
    elif (pitch_type in breakings):
        return 3

def append_previous_pitch_class(pitches):
    temp_pitches = pitches.copy().reset_index()
    temp_pitches['key'] = temp_pitches.apply(lambda x: int('{}{}'.format(int(x['ab_id']), int(x['pitch_num']))), axis=1)
    temp_pitches['prev_key'] = temp_pitches['key'].apply(lambda x: x-1)
    joined_temp_pitches = temp_pitches.merge(right=temp_pitches,left_on='prev_key', right_on='key', how='left')
    joined_temp_pitches = joined_temp_pitches[['index_x','pitch_class_y']]
    pitches = pitches.merge(right=joined_temp_pitches, left_index=True, right_on='index_x')
    pitches = pitches.rename(columns={'pitch_class_y':'prev_pitch_class'})
    pitches['prev_pitch_class'] = pitches['prev_pitch_class'].replace(nan, 0)
    return pitches

def load_pitches(atbat_ids = ''):
    pitches = pd.read_csv('./data/pitches.csv')
    pitches = pitches.reindex(sorted(pitches), axis=1)
    if (atbat_ids != ''):
        pitches = pitches.loc[(pitches['ab_id'].isin(atbat_ids))]

    # remove anything that's not a recognized pitch type
    pitches = pitches[pitches['pitch_type'].isin(valid_pitches)]
    pitches['pitch_class'] = pitches['pitch_type'].apply(lambda x: pitch_class(x))
    pitches = append_previous_pitch_class(pitches)
    pitches['pitch_class'] = pitches['pitch_class'].astype('category')
    pitches['prev_pitch_class'] = pitches['prev_pitch_class'].astype('category')

    return pitches[columns_of_concern]


def write_to_file(name, data):
    if (not os.path.exists('output')):
        os.makedirs('output')
    data.to_csv('output/{}_{}_pitch_probs.csv'.format(name[0], name[1]))

def write_model_compare_results(results):
    if (not os.path.exists('output')):
        os.makedirs('output')
    results_file = open("output/results.txt", "a")
    results_file.write("\n\n")
    
    results_file.write("-----------------------------------------")
    results_file.write("\nPitcher: {}".format(results['pitcher']))
    
    results_file.write("\n\tBest Model: {}".format(results['best_model']))

    results_file.write("\n\n\tLog Regression - ")
    results_file.write("\n\t\tscore: {}".format(results['log_regression']['score']))
    results_file.write("\n\t\tparameter(s):")
    for param in results['log_regression']['parameter(s)'].split(','):
        results_file.write("\n\t\t\t{}".format(param))
    
    results_file.write("\n\tNeural Network - ")
    results_file.write("\n\t\tscore: {}".format(results['neural_network']['score']))
    results_file.write("\n\t\tparameter(s):")
    for param in results['neural_network']['parameter(s)'].split(','):
        results_file.write("\n\t\t\t{}".format(param))
    
    results_file.write("\n\tDecision Tree - ")
    results_file.write("\n\t\tscore: {}".format(results['decision_tree']['score']))
    results_file.write("\n\t\tparameter(s):")
    for param in results['decision_tree']['parameter(s)'].split(','):
        results_file.write("\n\t\t\t{}".format(param))
    
    results_file.write("\n\tRandom Forest - ")
    results_file.write("\n\t\tscore: {}".format(results['random_forest']['score']))
    results_file.write("\n\t\tparameter(s):")
    for param in results['random_forest']['parameter(s)'].split(','):
        results_file.write("\n\t\t\t{}".format(param))
    results_file.write("\n-----------------------------------------")
    results_file.close()