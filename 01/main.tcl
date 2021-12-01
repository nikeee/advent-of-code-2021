#!/usr/bin/env tclsh

# Run:
#     ./main.tcl

set input [open "input.txt" r]
set lines [split [read $input] "\n"]
close $input;

set count 0
set last_distance -1

foreach distance $lines {
	if {$last_distance >= 0 && $distance > $last_distance} {
		incr count
	}
	set last_distance $distance
}

puts "Number of increased measurements; Part 1: $count"
