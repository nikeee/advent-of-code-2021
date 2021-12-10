#!/usr/bin/env julia
# Usage:
#    ./main.jl < input.txt
# Runtime version:
# $ julia --version
#     julia version 1.7.0

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
            push!(lowpoints, (x, y, value))
        end
    end
end

part1solution = sum(map((p) -> p[3] + 1, lowpoints))
@printf("Sum of the risk of the lowest points; Part 1: %d\n", part1solution)

# As per style-guide, names in julia should always be smashed-together lower-case names
function collectbasinneighbors(matrix, visitedpoints, position)
    if in(position, visitedpoints)
        return
    end
    push!(visitedpoints, position)

    x, y = position
    height, width = size(matrix)[1], size(matrix[1])[1]
    n = matrix[y][x]

    if x > 1 && matrix[y][x - 1] != 9 && matrix[y][x - 1] > n
        collectbasinneighbors(matrix, visitedpoints, (x - 1, y))
    end
    if x < width && matrix[y][x + 1] != 9 && matrix[y][x + 1] > n
        collectbasinneighbors(matrix, visitedpoints, (x + 1, y))
    end
    if y > 1 && matrix[y - 1][x] != 9 && matrix[y - 1][x] > n
        collectbasinneighbors(matrix, visitedpoints, (x, y - 1))
    end
    if y < height && matrix[y + 1][x] != 9 && matrix[y + 1][x] > n
        collectbasinneighbors(matrix, visitedpoints, (x, y + 1))
    end
end

basinsizes = []
for (x, y, _) in lowpoints
    visitedpoints = Set()
    collectbasinneighbors(matrix, visitedpoints, (x, y))
    push!(basinsizes, length(visitedpoints))
end

basinsizes = sort(basinsizes, rev=true)
part2solution = reduce(*, basinsizes[1:3])
@printf("Sizes of three largest basins, multiplied; Part 2: %d\n", part2solution)
