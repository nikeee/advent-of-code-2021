# Compile:
#     nim c -d:release main.nim
# Use:
#     ./main < input.txt
# Compiler version:
#     nim --version
#     Nim Compiler Version 1.6.0 [Linux: amd64]

# d run --rm -it -v $(pwd):/src --entrypoint /bin/bash nimlang/nim

import std/sugar
import std/strutils
import std/sequtils
import std/sets

var lines = newSeq[string]()
for line in stdin.lines:
    lines.add(line)

type
    Coordinate = tuple[x: int, y: int]
    SheetDefinition = tuple[data: HashSet[Coordinate], width: int, height: int]

let instructions = lines.filterIt(it.startsWith("fold along") and it.len > 0)
let initialSheetData = toHashSet(
    lines
    .filterIt(not it.startsWith("fold along") and it.len > 0)
    .mapIt(it.split(",").map(parseInt))
    .mapIt(Coordinate (it[0], it[1]))
)

let initialSheet = SheetDefinition (
    initialSheetData,
    max(initialSheetData.mapIt(it.x)) + 1,
    max(initialSheetData.mapIt(it.y)) + 1,
)

func foldSheet(sheet: SheetDefinition, instruction: string): SheetDefinition =
    let splitInstruction = instruction.split("=")
    let (dir, location) = (splitInstruction[0][^1], parseInt(splitInstruction[1]))

    let (_, width, height) = sheet;

    if dir == 'y':
        # This is horrible inefficient.
        # We should copy the input set and just move thepoints around without creating another new set.

        var effectiveSheet = sheet.data
        if location < height - location - 1:
            var turnedSheet: HashSet[Coordinate]
            for (x, y) in sheet.data:
                turnedSheet.incl((x, height - y))
            effectiveSheet = turnedSheet

        # There is no set.filter() :(
        var nextSheet: HashSet[Coordinate]
        for pos in effectiveSheet:
            if pos.y < location:
                nextSheet.incl(pos)
            else:
                let pos_on_new_sheet = location + location - pos.y
                nextSheet.incl((x: pos.x, y: pos_on_new_sheet))

        return (nextSheet, width, location)

    elif dir == 'x':
        var effectiveSheet = sheet.data
        if location < width - location - 1:
            var turnedSheet: HashSet[Coordinate]
            for (x, y) in sheet.data:
                turnedSheet.incl((width - x, y))
            effectiveSheet = turnedSheet

        # There is no set.filter() :(
        var nextSheet: HashSet[Coordinate]
        for pos in effectiveSheet:
            if pos.x < location:
                nextSheet.incl(pos)
            else:
                let pos_on_new_sheet = location + location - pos.x
                nextSheet.incl((x: pos_on_new_sheet, y: pos.y))

        return (nextSheet, location, height)

    assert false
    return sheet

let solution = foldSheet(initialSheet, instructions[0])
echo "Number of dots after first fold; Part 1: ", solution.data.len
