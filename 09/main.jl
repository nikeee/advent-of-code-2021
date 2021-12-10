#!/usr/bin/env julia

using Base.Iterators
using Printf

input = chomp.(readlines())

matrix = map((row) -> map(c -> parse(Int, c), split(row, "")), input)
height, width = size(matrix)[1], size(matrix[1])[1]

lowpoints = []
for y in 1:height
    for x in 1:width
        value = matrix[y][x]
        if (x == 1 || matrix[y][x - 1] > value) && (x >= width || matrix[y][x + 1] > value) && (y == 1 || matrix[y - 1][x] > value) && (y >= height || matrix[y + 1][x] > value)
            push!(lowpoints, value)
        end
    end
end

part1solution = sum(map((x) -> x + 1, lowpoints))
@printf("Sum of the risk of the lowest points; Part 1: %d\n", part1solution)
