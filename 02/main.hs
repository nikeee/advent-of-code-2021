-- Compile:
--     ghc -O3 main.hs
-- Use:
--     ./main < input.txt

import Data.List

data BoatState = BoatState {
    depth :: Integer,
    horizontal :: Integer,
    aim :: Integer
}

data Instruction = String Integer

reduceStatePart1 state (operation, amount) = do
    case operation of
        "up" -> state { depth = (depth state) - amount }
        "down" -> state { depth = (depth state) + amount }
        "forward" -> state { horizontal = (horizontal state) + amount }

reduceStatePart2 state (operation, amount) = do
    case operation of
        "up" -> state { aim = (aim state) - amount }
        "down" -> state { aim = (aim state) + amount }
        "forward" -> state {
            horizontal = (horizontal state) + amount,
            depth = (depth state) + (aim state) * amount
        }

parseInstruction instructionStr = do
    let splitInstruction = split ' ' instructionStr
    let amount = read (splitInstruction!!1) :: Integer
    (splitInstruction!!0, amount)

-- https://stackoverflow.com/a/46595679
split delimiter str = case break (==delimiter) str of
                (a, delimiter:b) -> a : split delimiter b
                (a, "")    -> [a]


computeSolution state = (horizontal state) * (depth state)

main = do
    input <- getContents
    let nonEmptyLines = filter ((> 2) . length) (lines input)
    let instructions = map parseInstruction nonEmptyLines

    let finalStatePart1 = foldl reduceStatePart1 (BoatState 0 0 0) instructions
    putStr "U-Boat position; Part 1: "
    print (computeSolution finalStatePart1)

    let finalStatePart2 = foldl reduceStatePart2 (BoatState 0 0 0) instructions
    putStr "U-Boat position with aim; Part 2: "
    print (computeSolution finalStatePart2)
