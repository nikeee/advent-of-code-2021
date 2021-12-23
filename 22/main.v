// Compile:
//     v main.v
// Use:
//     ./main < input.txt
// Compilier Version:
//     v version
//     V 0.2.4 ed2d128

import os
import arrays
import math.util { imin, imax }

struct Range {
	start int
	end int
}

fn (this Range) size() int {
	return this.end - this.start + 1
}

struct Cuboid {
	factor int
	x Range
	y Range
	z Range
}
fn (this Cuboid) volume() int {
	return this.x.size() * this.y.size() * this.z.size()
}

fn (this Cuboid) intersects_with(other Cuboid) bool {
	return (other.x.end >= this.x.start && other.x.start <= this.x.end) &&
			(other.y.end >= this.y.start && other.y.start <= this.y.end) &&
			(other.z.end >= this.z.start && other.z.start <= this.z.end)
}

fn (this Cuboid) intersection(other Cuboid, factor int) Cuboid {
	return Cuboid {
		factor,
		Range { imax(this.x.start, other.x.start), imin(this.x.end, other.x.end) },
		Range { imax(this.y.start, other.y.start), imin(this.y.end, other.y.end) },
		Range { imax(this.z.start, other.z.start), imin(this.z.end, other.z.end) },
	}
}

fn parse_cuboid(line string) Cuboid {
	split := line.split(' ')
	xyz := split[1].split(',')
	xr := xyz[0].split('=')[1]
	yr := xyz[1].split('=')[1]
	zr := xyz[2].split('=')[1]

	xs := xr.split('..').map(it.int())
	ys := yr.split('..').map(it.int())
	zs := zr.split('..').map(it.int())

	return Cuboid {
		if split[0] == 'on' { 1 } else { -1 },
		Range { xs[0], xs[1] },
		Range { ys[0], ys[1] },
		Range { zs[0], zs[1] },
	}
}


fn main() {
	input := os.get_lines()
	cuboids := input.map(parse_cuboid(it))[..20]

	mut effective_cubes := []Cuboid{}
	for cuboid in cuboids {
		for prev_cuboid in effective_cubes.clone() {
			if prev_cuboid.intersects_with(cuboid) {
				effective_cubes << cuboid.intersection(prev_cuboid, -prev_cuboid.factor)
			}
		}
		if cuboid.factor > 0 {
			effective_cubes << cuboid
		}
	}

	sum := arrays.sum(effective_cubes.map(it.volume() * it.factor))?
	println('Lit cubes after first part of init procedure; Part 1: ${sum}')
}
