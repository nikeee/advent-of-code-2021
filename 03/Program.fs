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

let mapBits (bitCount : int) (input : seq<string>) (mapperFn : int -> string) : string =
    seq {0 .. (bitCount - 1)}
    |> Seq.map (compareBits input)
    |> Seq.map (mapperFn)
    |> String.concat ""

[<EntryPoint>]
let main _ =
    let input = readlines() |> Set.ofSeq
    let bitCount = input
                    |> Seq.map String.length
                    |> Seq.max

    let gamma = mapBits bitCount input (fun r -> if r >= 0 then "1" else "0") |> parseBinary
    let epsilon = mapBits bitCount input (fun r -> if r >= 0 then "0" else "1") |> parseBinary
    printfn "Power consumption; Part 1: %d" (gamma * epsilon)
    0
