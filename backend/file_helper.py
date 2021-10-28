from numpy import NaN, nan
import pandas as pd
valid_pitches = ['CH', 'CU', 'EP', 'KC', 'KN', 'SC', 'SL','FA', 'FC', 'FF', 'FS', 'FT', 'SI']

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

def load_pitches(atbat_ids = ''):
    pitches = pd.read_csv('./data/pitches.csv')
    pitches = pitches.reindex(sorted(pitches), axis=1)
    if (atbat_ids != ''):
        pitches = pitches.loc[(pitches['ab_id'].isin(atbat_ids))]

    # remove anything that's not a recognized pitch type
    pitches = pitches[pitches['pitch_type'].isin(valid_pitches)]
    
    return pitches
