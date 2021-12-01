#!/usr/bin/env tclsh

# Run:
#     ./main.tcl

set input [open "input.txt" r]
set lines [split [read $input] "\n"]
close $input;

set count_part_1 0
set last_distance -1

foreach distance $lines {
	if {$last_distance >= 0 && $distance > $last_distance} {
		incr count_part_1
	}
	set last_distance $distance
}

puts "Number of increased measurements; Part 1: $count_part_1"

set windowed_distances {}
for { set i 0 } { $i < ([llength $lines] - 2) } { incr i } {
	set windowed_distance 0

	set window_index $i
	incr windowed_distance [lindex $lines $window_index]

	incr window_index
	incr windowed_distance [lindex $lines $window_index]

	incr window_index
	incr windowed_distance [lindex $lines $window_index]

	lappend windowed_distances $windowed_distance
}

set count_part_2 0
set last_distance -1

foreach distance $windowed_distances {
	if {$last_distance >= 0 && $distance > $last_distance} {
		incr count_part_2
	}
	set last_distance $distance
}

puts "Number of increased measurements in sliding windows; Part 2: $count_part_2"
