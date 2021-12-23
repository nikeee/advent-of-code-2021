// Compile:
//     v main.v
// Use:
//     ./main < input.txt
// Compilier Version:
//     v version
//     V 0.2.4 ed2d128

import os
import arrays

struct Range {
	start i64
	end i64
}

fn (this Range) size() i64 {
	return this.end - this.start + 1
}

struct Cuboid {
	factor int
	x Range
	y Range
	z Range
}
fn (this Cuboid) volume() i64 {
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
		Range { i64max(this.x.start, other.x.start), i64min(this.x.end, other.x.end) },
		Range { i64max(this.y.start, other.y.start), i64min(this.y.end, other.y.end) },
		Range { i64max(this.z.start, other.z.start), i64min(this.z.end, other.z.end) },
	}
}

fn i64max(a i64, b i64) i64 {
	return if a > b { a } else { b }
}
fn i64min(a i64, b i64) i64 {
	return if a < b { a } else { b }
}

fn parse_cuboid(line string) Cuboid {
	split := line.split(' ')
	xyz := split[1].split(',')
	xr := xyz[0].split('=')[1]
	yr := xyz[1].split('=')[1]
	zr := xyz[2].split('=')[1]

	xs := xr.split('..').map(it.i64())
	ys := yr.split('..').map(it.i64())
	zs := zr.split('..').map(it.i64())

	return Cuboid {
		if split[0] == 'on' { 1 } else { -1 },
		Range { xs[0], xs[1] },
		Range { ys[0], ys[1] },
		Range { zs[0], zs[1] },
	}
}

fn count_lit_cuboids(cuboids []Cuboid) i64 {
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

	return arrays.sum(effective_cubes.map(it.volume() * it.factor)) or { 0 }
}

fn main() {
	input := os.get_lines()
	cuboids := input.map(parse_cuboid(it))

	println('Lit cubes after first part of init procedure; Part 1: ${count_lit_cuboids(cuboids.clone()[..20])}')
	println('Lit cubes after entire reboot; Part 2: ${count_lit_cuboids(cuboids.clone())}')
}

