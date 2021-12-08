#!/usr/bin/env swipl
% Usage:
%     ./main.pl < input.txt

:- use_module(library(lists)).

str_is_digit(S, Digit) :- string_chars(S, L), is_digit(L, Digit).

set_equal(X, Y) :-
    subtract(X, Y, []),
    subtract(Y, X, []).

is_digit(S, 1) :- length(S, 2).
is_digit(S, 4) :- length(S, 4).
is_digit(S, 7) :- length(S, 3).
is_digit(S, 8) :- length(S, 7).

main :-
    read_string(user_input, _, S),
    split_string(S, "\n", "", Lines),
    process_lines(Lines, Part1Solution),
    format('Number of 1s, 4s, 7s and 8s; Part 1: ~d', [Part1Solution]),
    nl.

process_lines([], 0).
process_lines([H|T], Sum) :-
    process_entry(H, LineResult),
    process_lines(T, Rest),
    Sum is (LineResult + Rest).

process_entry("", 0).
process_entry(Line, Count) :-
    split_string(Line, "|", " ", Data),

    nth0(1, Data, DigitSegmentStr),
    split_string(DigitSegmentStr, " ", "", DigitSegments),

    count_relevant_digits(DigitSegments, Count).

count_relevant_digits([], 0).
count_relevant_digits([H|T], Count) :-
    count_relevant_digits(T, Rest),
    (
        (str_is_digit(H, 1) ; str_is_digit(H, 4) ; str_is_digit(H, 7) ; str_is_digit(H, 8)) -> (Count is 1 + Rest) ; Count is Rest
    ).


:- initialization(main, main).
