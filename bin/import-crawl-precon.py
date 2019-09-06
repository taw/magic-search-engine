#!/usr/bin/env python3

import sys

import datetime
import json
import pathlib
import xml.etree.ElementTree

import more_itertools # PyPI: more-itertools

CACHE = {}
PRECONS_PATH = pathlib.Path('data/crawl-precons.json')

def custom_sets():
    if 'custom_sets' not in CACHE:
        CACHE['custom_sets'] = {}
        for set_path in pathlib.Path('data/sets').iterdir():
            with set_path.open() as f:
                set_file = json.load(f)
            if set_file.get('custom', False):
                CACHE['custom_sets'][set_file['code']] = set_file
    return CACHE['custom_sets']

def find_card(card_name, set_code=None):
    return more_itertools.one(
        (set_file['code'], iter_card)
        for set_file in custom_sets().values()
        for iter_card in set_file['cards']
        if iter_card['name'] == card_name
        and (set_code is None or set_file['code'] == set_code)
    )

def parse_zone(deck_xml, zone_name):
    zone = deck_xml.find(f'./zone[@name="{zone_name}"]')
    result = []
    for card in zone:
        card_name = card.get('name')
        if '‘' not in card_name:
            card_name = card_name.replace('’', "'")
        try:
            set_code, card_info = find_card(card_name)
        except ValueError:
            if card_name[:3] in custom_sets() and card_name[3] == ' ':
                set_code, card_name = card_name.split(' ', 1)
            else:
                card_name = input(f'[ ?? ] rename {card_name} to ')
                set_code = input(f'[ ?? ] set code for {card_name}: ')
            try:
                set_code, card_info = find_card(card_name, set_code)
            except ValueError as e:
                raise ValueError(f'Error in card {card.get("name")}') from e
        result.append([int(card.get('number')), set_code, card_info['number']])
    return result

if __name__ == '__main__':
    deck_xml = xml.etree.ElementTree.parse(sys.argv[1]).getroot()
    with PRECONS_PATH.open() as f:
        precons = json.load(f)
    precons.append({
        'cards': parse_zone(deck_xml, 'main'),
        'name': deck_xml.find('./deckname').text,
        'release_date': sys.argv[3] if len(sys.argv) > 3 else f'{datetime.datetime.utcnow().date():%Y-%m-%d}',
        'set_code': sys.argv[2],
        'set_name': custom_sets()[sys.argv[2]]['name'],
        'sideboard': parse_zone(deck_xml, 'side'),
        'type': 'Brawl Deck'
    })
    with PRECONS_PATH.open('w') as f:
        json.dump(precons, f, indent=4, sort_keys=True)
        print(file=f)
