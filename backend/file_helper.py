from numpy import nan
import pandas as pd
valid_pitches = ['CH', 'CU', 'KC', 'KN', 'SC', 'SL','FA', 'FC', 'FF', 'FS', 'FT', 'SI']
fastballs = ['FC', 'FF', 'FS', 'FT', 'SI','FA']
offspeeds = ['CH', 'KN']
breakings = ['CU', 'KC', 'SC', 'SL']
columns_of_concern = ['ab_id', 'pitch_num', 'b_count', 's_count', 'on_1b', 'on_2b', 'on_3b', 'outs', 'pitch_class', 'prev_pitch_class']

def load_players(name=('', '')):
    players = pd.read_csv('./data/player_names.csv')
    if ((name != ('',''))):
        players = players.loc[(players['first_name'] == name[0]) & (players['last_name'] == name[1])]
    return players


def load_atbats(pitcher_id = ''):
    atbats = pd.read_csv('./data/atbats.csv')
    atbats = atbats.reindex(sorted(atbats), axis=1)
    if (pitcher_id != ''):
        atbats = atbats.loc[(atbats['pitcher_id'] == pitcher_id)]
    atbats['stand'] = atbats['stand'].replace('L', 1.0)
    atbats['stand'] = atbats['stand'].replace('R', 0.0)
    return atbats

def pitch_class(pitch_type):
    if (pitch_type in fastballs):
        return 'fast'
    elif (pitch_type in offspeeds):
        return 'off'
    elif (pitch_type in breakings):
        return 'break'
    else:
        print('Found a pitch I do not recognize: {}'.format(pitch_type))
        return 'unknown'

def append_previous_pitch_class(pitches):
    temp_pitches = pitches.copy().reset_index()
    temp_pitches['key'] = temp_pitches.apply(lambda x: int('{}{}'.format(int(x['ab_id']), int(x['pitch_num']))), axis=1)
    temp_pitches['prev_key'] = temp_pitches['key'].apply(lambda x: x-1)
    joined_temp_pitches = temp_pitches.merge(right=temp_pitches,left_on='prev_key', right_on='key', how='left')
    joined_temp_pitches = joined_temp_pitches[['index_x','pitch_class_y']]
    pitches = pitches.merge(right=joined_temp_pitches, left_index=True, right_on='index_x')
    pitches = pitches.rename(columns={'pitch_class_y':'prev_pitch_class'})
    pitches['prev_pitch_class'] = pitches['prev_pitch_class'].replace(nan, 'unknown')
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

    return pitches[columns_of_concern]
