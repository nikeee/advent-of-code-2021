// Run:
//     dotnet run -c Release < input.txt

open System

let rec readlines () = seq {
    let line = Console.ReadLine()
    if line <> null then
        yield line
        yield! readlines ()
}

let parseBinary value = Convert.ToInt32(value, 2)

// Returns > 0 if there are more ones, < 0 if there are more zeros
let compareBits (input : seq<string>) (bitIndex : int) : int =
    input
    |> Seq.map (fun line -> line.[bitIndex])
    |> Seq.sumBy (fun bit -> if bit = '1' then 1 else -1)

let mapBitsPart1 (bitCount : int) (input : seq<string>) (mapperFn : int -> string) : string =
    seq {0 .. (bitCount - 1)}
    |> Seq.map (compareBits input)
    |> Seq.map mapperFn
    |> String.concat ""

let rec filterBitsByConsecutiveMostFrequent (candidates : Set<string>) (currentBit : int) (getRelevantBit : int -> char) =
    let bitComparison = compareBits candidates currentBit
    let mostFrequentBit = getRelevantBit bitComparison

    let nextValidCandidates = candidates
                                |> Seq.filter (fun c -> c.[currentBit] = mostFrequentBit)
                                |> Set.ofSeq
    if nextValidCandidates.Count = 1
    then nextValidCandidates |> Seq.head
    else filterBitsByConsecutiveMostFrequent nextValidCandidates (currentBit + 1) getRelevantBit

[<EntryPoint>]
let main _ =
    let input = readlines() |> Set.ofSeq
    let bitCount = input
                    |> Seq.map String.length
                    |> Seq.max

    let gamma = mapBitsPart1 bitCount input (fun r -> if r >= 0 then "1" else "0") |> parseBinary
    let epsilon = mapBitsPart1 bitCount input (fun r -> if r >= 0 then "0" else "1") |> parseBinary
    printfn "Power consumption; Part 1: %d" (gamma * epsilon)

    let oxygen = filterBitsByConsecutiveMostFrequent input 0 (fun cmp -> if cmp >= 0 then '1' else '0') |> parseBinary
    let co2 = filterBitsByConsecutiveMostFrequent input 0 (fun cmp -> if cmp >= 0 then '0' else '1') |> parseBinary
    printfn "Life Support Rating; Part 2: %d" (oxygen * co2)
    0
