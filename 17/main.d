// Use:
//     dmd -run main.d < input.txt
// Or compile and run:
//     dmd -O -release -inline main.d
//     ./main < input.txt

import std.conv;
import std.stdio;
import std.string;
import std.container.rbtree;
import std.typecons : tuple;
import std.algorithm.comparison : min, max;

alias Vector = tuple!("x", "y");

void main() {
	string input = strip(stdin.readln()); // "target area: x=20..30, y=-10..-5"

	auto ta = input.split(": ")[1]; // "x=20..30, y=-10..-5"
	auto ta_data = ta.split(", "); // "x=20..30", "y=-10..-5"
	ta_data[0] = ta_data[0].split("=")[1]; // "20..30"
	ta_data[1] = ta_data[1].split("=")[1]; // "-10..-5"

	auto first_split = ta_data[0].split(".."); // "20", "30"
	auto second_split = ta_data[1].split(".."); // "-10", "-5"

	auto ta_x0 = to!int(first_split[0], 10);
	auto ta_x1 = to!int(first_split[1], 10);
	auto ta_y0 = to!int(second_split[0], 10);
	auto ta_y1 = to!int(second_split[1], 10);

	auto ta_start = Vector(min(ta_x0, ta_x1), min(ta_y0, ta_y1));
	auto ta_end = Vector(max(ta_x0, ta_x1), max(ta_y0, ta_y1));

	auto acceleration = Vector(-1, -1);

	// A Red Black tree with the highest element at front
	auto highest_ys = redBlackTree!("a > b", int);

	// There might be more efficient solutions for this problem, but we take the simple approach and just check some initial conditions
	foreach (initial_velocity_x; 0..100) {
		foreach (initial_velocity_y; -1000..1000) {

			int highest_y = -1;
			auto pos = Vector(0, 0);
			auto velocity = Vector(initial_velocity_x, initial_velocity_y);

			while (true) {
				if (pos.x < ta_start.x && velocity.x == 0) {
					// Not moving in x direction any more, cannot reach target in any way
					break;
				}

				if (pos.y > highest_y) {
					highest_y = pos.y;
				}
				if (pos.x >= ta_start.x && pos.x <= ta_end.x && pos.y >= ta_start.y && pos.y <= ta_end.y) {
					// target area was hit, add highest_y to list and finish check
					highest_ys.insert([highest_y]);
					break;
				}

				if (pos.x > ta_end.x || pos.y < ta_end.y) {
					// target missed
					break;
				}

				pos = Vector(pos.x + velocity.x, pos.y + velocity.y);
				velocity = Vector(velocity.x + acceleration.x, velocity.y + acceleration.y);
				if (velocity.x < 0) {
					velocity.x = 0;
				}

			}
		}
	}

	writefln("Highest y coordinate of paths that hit the target; Part 1: %d", highest_ys.front);
}
