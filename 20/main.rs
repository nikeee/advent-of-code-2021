// Compile:
//     rustc -C opt-level=3 main.rs
// Use:
//     ./main < input.txt

use std::collections::HashSet;
use std::io::{self, BufRead};
use std::vec::Vec;

#[derive(Eq, PartialEq, Hash, Debug)]
struct Point {
	x: i32,
	y: i32,
}

fn main() {
	let stdin = io::stdin();
	let lines: Vec<String> = stdin
		.lock()
		.lines()
		.map(|s| s.unwrap())
		.filter(|s| s.len() > 0)
		.collect();

	let lookup_table: Vec<bool> = lines[0].chars().map(|c| c == '#').collect();

	let input_image = &lines[1..];

	let height = input_image.len();
	let width = input_image[0].len();

	let mut lit_pixels = HashSet::new();
	for y in 0..height {
		for (x, c) in input_image[y].chars().enumerate() {
			if c == '#' {
				lit_pixels.insert(Point {
					x: x as i32,
					y: y as i32,
				});
			}
		}
	}

	let iterations: i32 = 2;

	let mut pixel_function: Box<dyn Fn(i32, i32) -> bool> =
		Box::new(move |x, y| lit_pixels.contains(&Point { x, y }));

	for _ in 0..iterations {
		pixel_function = create_image_layer(lookup_table.clone(), pixel_function);
	}

	let min_x = -iterations;
	let max_x = width as i32 + iterations;
	let min_y = -iterations;
	let max_y = height as i32 + iterations;

	let lit_pixel_count = count_pixels(pixel_function, min_x, max_x, min_y, max_y);

	println!(
		"Number of lit pixels after two iteration of image enhancement: {}",
		lit_pixel_count
	);
}

fn count_pixels(
	pixel_function: Box<dyn Fn(i32, i32) -> bool>,
	min_x: i32,
	max_x: i32,
	min_y: i32,
	max_y: i32,
) -> usize {
	let mut lit_pixels: usize = 0;
	for y in min_y..=max_y {
		for x in min_x..=max_x {
			lit_pixels += pixel_function(x, y) as usize;
		}
	}
	lit_pixels
}

fn create_image_layer(
	lookup_table: Vec<bool>,
	pixel_function: Box<dyn Fn(i32, i32) -> bool>,
) -> Box<dyn Fn(i32, i32) -> bool> {
	let res = move |x, y| {
		let mut lookup_index: u16 = 0;
		lookup_index |= pixel_function(x - 1, y - 1) as u16;
		lookup_index <<= 1;
		lookup_index |= pixel_function(x + 0, y - 1) as u16;
		lookup_index <<= 1;
		lookup_index |= pixel_function(x + 1, y - 1) as u16;
		lookup_index <<= 1;
		lookup_index |= pixel_function(x - 1, y + 0) as u16;
		lookup_index <<= 1;
		lookup_index |= pixel_function(x + 0, y + 0) as u16;
		lookup_index <<= 1;
		lookup_index |= pixel_function(x + 1, y + 0) as u16;
		lookup_index <<= 1;
		lookup_index |= pixel_function(x - 1, y + 1) as u16;
		lookup_index <<= 1;
		lookup_index |= pixel_function(x + 0, y + 1) as u16;
		lookup_index <<= 1;
		lookup_index |= pixel_function(x + 1, y + 1) as u16;

		lookup_table[lookup_index as usize]
	};
	Box::new(res)
}
