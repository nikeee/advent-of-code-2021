#!/usr/bin/env python3
# Usage:
#    ./main.py < input.txt
# Version:
#    python3 --version
#    Python 3.8.10

import sys
from functools import lru_cache
from typing import Tuple

input_lines = tuple(
    l.strip().split(': ')[1]
    for l in sys.stdin
    if len(l) > 0
)

initial_player_positions = (
    int(input_lines[0]),
    int(input_lines[1])
)

def part1():
    def create_deterministic_die():
        rolls = 0
        while True:
            for c in range(1, 101):
                rolls += 1
                yield c, rolls

    player_positions = list(initial_player_positions)
    player_score = [0, 0]

    rolls = 0
    moving_player = 0
    die = create_deterministic_die()

    while player_score[0] < 1000 and player_score[1] < 1000:
        r0, rolls = die.__next__()
        r1, rolls = die.__next__()
        r2, rolls = die.__next__()
        roll = r0 + r1 + r2

        next_position = (player_positions[moving_player] + roll - 1) % 10 + 1
        player_positions[moving_player] = next_position
        player_score[moving_player] += next_position

        moving_player += 1
        moving_player %= len(player_positions)

    return min(player_score) * rolls


def part2():
    # The approach from part 2 doesn't work here. We use recursion instead of iteration to simulate each turn

    MAX_SCORE = 21

    # Important observation: We only have 7 different outcomes for any combination of dice throws (3, 4, 5, 6, 7, 8, 9)
    # However, they are not evenly distributed. Instead of doing a 3-way-nested loop, we can just create them once with this weird list comprehension
    possible_roll_sums = tuple(
        first_roll + second_roll + third_roll
        for first_roll in range(1, 4)
        for second_roll in range(1, 4)
        for third_roll in range(1, 4)
    )

    # maxsize=None is important here; otherwise, only 128 entries are cached, but we actually need all of them
    @lru_cache(maxsize=None)
    def dirac_game_step(scores: Tuple[int, int], positions: Tuple[int, int], roll_sum: int, current_player: int) -> Tuple[int, int]:
        positions = list(positions)
        scores = list(scores)

        next_position = (positions[current_player] + roll_sum - 1) % 10 + 1
        positions[current_player] = next_position
        scores[current_player] += next_position

        if scores[0] >= MAX_SCORE or scores[1] >= MAX_SCORE:
            return (1, 0) if scores[0] >= MAX_SCORE else (0, 1)

        next_player = (current_player + 1) % 2

        next_step_results = [
            dirac_game_step(tuple(scores), tuple(positions), rs, next_player)
            for rs in possible_roll_sums
        ]

        return (
            sum(map(lambda r: r[0], next_step_results)),
            sum(map(lambda r: r[1], next_step_results)),
        )

    def play_dirac_game():
        universe_results = tuple(
            dirac_game_step((0, 0), initial_player_positions, rs, 0)
            for rs in possible_roll_sums
        )

        return (
            sum(map(lambda r: r[0], universe_results)),
            sum(map(lambda r: r[1], universe_results)),
        )

    game_results = play_dirac_game()
    return max(game_results)

if __name__ == '__main__':
    part1_solution = part1()
    print(f'Score of the losing player multiplied by number of dies rolled (deterministic); Part 1: {part1_solution}')

    part2_solution = part2()
    print(f'Number of won universes; Part 2: {part2_solution}')
