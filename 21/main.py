#!/usr/bin/env python3
# Usage:
#    ./main.py < input.txt
# Version:
#    python3 --version
#    Python 3.8.10

import sys
from functools import reduce

lines = tuple(map(lambda s: s.strip(), filter(lambda l: len(l) > 0, sys.stdin)))

def deterministic_die():
    rolls = 0
    while True:
        for c in range(1, 101):
            rolls += 1
            yield c, rolls

moving_player = 0
player_pos = [
    int(lines[0].split(': ')[1]),
    int(lines[1].split(': ')[1])
]
player_score = [0, 0]

rolls = 0
die = deterministic_die()

while player_score[0] < 1000 and player_score[1] < 1000:
    r0, rolls = die.__next__()
    r1, rolls = die.__next__()
    r2, rolls = die.__next__()
    roll = r0 + r1 + r2

    player_pos[moving_player] += roll
    player_pos[moving_player] -= 1
    player_pos[moving_player] %= 10
    player_pos[moving_player] += 1
    player_score[moving_player] += player_pos[moving_player]

    moving_player += 1
    moving_player %= len(player_pos)

print(f'Score of the losing player multiplied by number of dies rolled (deterministic); Part 1: {min(player_score) * rolls}')
