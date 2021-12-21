// Compile:
//     rustc -C opt-level=3 main.rs
// Use:
//     ./main < input.txt

use std::collections::{HashMap, HashSet};
use std::io::{self, BufRead};
use std::vec::Vec;

#[derive(Eq, PartialEq, Hash, Clone, Debug)]
struct Point {
	x: i32,
	y: i32,
}

type PixelFunction = Box<dyn FnMut(i32, i32) -> bool>;

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

	// Problem: We cannot just create an array with a fixed size, as the relevant image size grows depending on the iteration count.
	// A pixel far out in the void may not be relevant in the first few iterations. Important observation: The void may not stay off, it might also change its lit status.

	let lit_pixel_count_part1 =
		enhance_image(lookup_table.clone(), lit_pixels.clone(), width, height, 2);
	println!(
		"Number of lit pixels after two iteration of image enhancement; Part 1: {}",
		lit_pixel_count_part1
	);

	let lit_pixel_count_part2 = enhance_image(lookup_table, lit_pixels, width, height, 50);
	println!(
		"Number of lit pixels after 50 iteration of image enhancement; Part 2: {}",
		lit_pixel_count_part2
	);
}

fn enhance_image(
	lookup_table: Vec<bool>,
	input_image: HashSet<Point>,
	input_width: usize,
	input_height: usize,
	iterations: i32,
) -> usize {
	let mut pixel_function_part1: PixelFunction =
		Box::new(move |x, y| input_image.contains(&Point { x, y }));

	for _ in 0..iterations {
		pixel_function_part1 = create_image_layer(lookup_table.clone(), pixel_function_part1);
	}

	count_pixels(pixel_function_part1, input_width, input_height, iterations)
}

fn create_image_layer(lookup_table: Vec<bool>, mut pixel_function: PixelFunction) -> PixelFunction {
	// When using a lot of layers, a lot of pixels are getting evaluated recursively, with up to 50 levels of recursion per pixel.
	// Not only that; to compute a pixel, we have to look at 9 pixels. To compute a single pixel on the last created layer 50,
	// we need to look at (9 * 9 * 9 * ...), appx. 9^50 pixels.
	// We try to keep the number down by saving the value of each pixel in each layer. That way, we can avoid doing unnecessary recursions.
	let mut layer_cache: HashMap<Point, bool> = HashMap::new();

	let res = move |x, y| {
		let p = Point { x, y };
		if let Some(computed_value) = layer_cache.get(&p) {
			return *computed_value;
		}

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

		let res = lookup_table[lookup_index as usize];
		layer_cache.insert(p, res);
		res
	};
	Box::new(res)
}

fn count_pixels(
	mut pixel_function: PixelFunction,
	initial_width: usize,
	initial_height: usize,
	iterations: i32,
) -> usize {
	// We can estimate the target size of the image we might end up getting.
	// Each iteration inflates the image by one row/column to the left/right/top/bottom
	// This is the area we need to query to count all relevant pixels

	let min_x = -iterations;
	let max_x = initial_width as i32 + iterations;
	let min_y = -iterations;
	let max_y = initial_height as i32 + iterations;

	let mut lit_pixels: usize = 0;
	for y in min_y..=max_y {
		for x in min_x..=max_x {
			lit_pixels += pixel_function(x, y) as usize;
		}
	}
	lit_pixels
}
