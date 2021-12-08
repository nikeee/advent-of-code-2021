#!/usr/bin/env swipl
% Usage:
%     ./main.pl < input.txt

:- use_module(library(lists)).

:- dynamic unique_pattern/1.
assert_unique_pattern(S) :- string_chars(S, P), assertz(unique_pattern(P)).

str_is_digit(S, Digit) :- string_chars(S, L), is_digit(L, Digit).

set_equal(X, Y) :-
    subtract(X, Y, []),
    subtract(Y, X, []).

valid_combo(S, Len) :- length(S, Len), unique_pattern(P), length(P, Len), set_equal(P, S).

% Used for part 1
is_digit_syntactic(S, 1) :- length(S, 2).
is_digit_syntactic(S, 4) :- length(S, 4).
is_digit_syntactic(S, 7) :- length(S, 3).
is_digit_syntactic(S, 8) :- length(S, 7).
str_is_syntactic_assured_digit(S, Digit) :- string_chars(S, L), is_digit_syntactic(L, Digit).

is_digit(S, 1) :- valid_combo(S, 2).
is_digit(S, 4) :- valid_combo(S, 4).
is_digit(S, 7) :- valid_combo(S, 3).
is_digit(S, 8) :- valid_combo(S, 7).
is_digit(S, 5) :-
    valid_combo(S, 5),
    is_digit(Six, 6), subtract(Six, S, Delta), length(Delta, 1).

is_digit(S, 2) :-
    valid_combo(S, 5),
    % is_digit(Eight, 8), subtract(Eight, S, BAndE),
    % is_digit(Zero, 0), subtract(Zero, S, BAndE),
    \+ is_digit(S, 5),
    \+ is_digit(S, 3),
    is_digit(One, 1), intersection(One, S, Intersection), length(Intersection, 1).

is_digit(S, 3) :-
    valid_combo(S, 5),
    \+ is_digit(S, 5),
    is_digit(One, 1), intersection(One, S, Intersection), length(Intersection, 2).

is_digit(S, 0) :-
    valid_combo(S, 6),
    \+ is_digit(S, 6),
    \+ is_digit(S, 9).

is_digit(S, 6) :-
    valid_combo(S, 6),
    is_digit(Digit1, 1),
    \+ subset(Digit1, S).

is_digit(S, 9) :-
    valid_combo(S, 6),
    is_digit(Digit4, 4),
    subset(Digit4, S).

main :-
    read_string(user_input, _, S),
    split_string(S, "\n", "", Lines),
    part1_process_lines(Lines, Part1Solution),
    format('Number of 1s, 4s, 7s and 8s; Part 1: ~d', [Part1Solution]), nl,
    part2_process_lines(Lines, Part2Solution),
    format('Sum of all numbers in input; Part 2: ~d', [Part2Solution]), nl.

% Part 1

part1_process_lines([], 0).
part1_process_lines([H|T], Sum) :-
    part1_process_entry(H, LineResult),
    part1_process_lines(T, Rest),
    Sum is (LineResult + Rest).

part1_process_entry("", 0).
part1_process_entry(Line, Count) :-
    split_string(Line, "|", " ", Data),

    nth0(1, Data, DigitSegmentStr),
    split_string(DigitSegmentStr, " ", "", DigitSegments),

    part1_count_relevant_digits(DigitSegments, Count).

part1_count_relevant_digits([], 0).
part1_count_relevant_digits([H|T], Count) :-
    part1_count_relevant_digits(T, Rest),
    (
        (
            str_is_syntactic_assured_digit(H, 1) ;
            str_is_syntactic_assured_digit(H, 4) ;
            str_is_syntactic_assured_digit(H, 7) ;
            str_is_syntactic_assured_digit(H, 8)
        ) -> (Count is 1 + Rest) ; Count is Rest
    ).

% Part 2

convert_digits_to_int(Digits, N) :-
    atomics_to_string(Digits, Str),
    atom_number(Str, N).

assert_patterns([]).
assert_patterns([H|T]) :-
    assert_unique_pattern(H),
    assert_patterns(T).

process_digits([], []).
process_digits([Segments|T], ResultDigits) :-
    str_is_digit(Segments, Digit),
    process_digits(T, RestDigits),
    append([Digit], RestDigits, ResultDigits).

part2_process_lines([], 0).
part2_process_lines([H|T], Sum) :-
    part2_process_entry(H, LineResult),
    part2_process_lines(T, Rest),
    Sum is (LineResult + Rest).

part2_process_entry("", 0).
part2_process_entry(Line, Result) :-
    split_string(Line, "|", " ", Data),

    nth0(0, Data, PatternsStr),
    split_string(PatternsStr, " ", "", Patterns),

    nth0(1, Data, DigitSegmentStr),
    split_string(DigitSegmentStr, " ", "", DigitSegments),

    retractall(unique_pattern(_)),
    assert_patterns(Patterns),

    process_digits(DigitSegments, Digits),
    convert_digits_to_int(Digits, Result),
    retractall(unique_pattern(_)).


:- initialization(main, main).
