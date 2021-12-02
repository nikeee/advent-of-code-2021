-- Compile:
--     ghc -O3 main.hs
-- Use:
--     ./main < input.txt

import Data.List

data BoatState = BoatState {
    depth :: Integer,
    horizontal :: Integer
}

data Instruction = String Integer

reduceState state (operation, amount) = do
    case operation of
        "up" -> state { depth = (depth state) - amount }
        "down" -> state { depth = (depth state) + amount }
        "forward" -> state { horizontal = (horizontal state) + amount }

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

    let initialState = BoatState 0 0
    let finalState = foldl reduceState initialState instructions
    let solution = computeSolution (finalState)
    print solution
