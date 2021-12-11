' Compile:
'     dotnet publish -c Release --self-contained --runtime linux-x64
' Run:
'     ./bin/Release/net6.0/linux-x64/publish/11 < input.txt
' Compiler version:
'     dotnet --version
'     6.0.100

imports System
imports System.Diagnostics
imports System.Linq
imports System.Collections.Generic

module Program
    function ReadInput() as integer(,)
        dim field(0,0) as integer


        dim line = Console.ReadLine()
        dim width = line.Length
        dim height = -1
        dim x = 0
        do
            dim rowData = line.ToCharArray().Select(function(c) integer.Parse(c)).ToArray()
            if height = -1 then
                height = rowData.Length
                field = new integer(width - 1, height - 1) { }
            end if

            for y = 0 to height - 1
                field(x, y) = rowData(y)
            next
            line = Console.ReadLine()
            x += 1
        loop until line is nothing
        return field
    end function

    iterator function GetNeighbors(width as integer, height as integer, x as integer, y as integer) as IEnumerable(of (x as integer, y as integer))
        if x > 0 then
            if y > 0 then yield (x - 1, y - 1)
            yield (x - 1, y)
            if y < height - 1 then yield (x - 1, y + 1)
        end if
        if y > 0 then yield (x, y - 1)
        if y < height - 1 then yield (x, y + 1)
        if x < width - 1 then
            if y > 0 then yield (x + 1, y - 1)
            yield (x + 1, y)
            if y < height - 1 then yield (x + 1, y + 1)
        end if
    end function

    function DeriveNextState(state as integer(,)) as (nextState as integer(,), flashCount as integer)
        dim nextState = DirectCast(state.Clone(), integer(,))
        dim width = nextState.GetLength(0)
        dim height = nextState.GetLength(1)

        for x = 0 to width - 1
            for y = 0 to height - 1
                nextState(x, y) += 1
            next
        next

        dim flashed(width - 1, height - 1) as boolean

        dim flashCount = 0
        dim newFlashOccurred as boolean
        do
            newFlashOccurred = false

            for x = 0 to width - 1
                for y = 0 to height - 1
                    if not flashed(x, y) andalso nextState(x, y) > 9 then
                        newFlashOccurred = true
                        flashed(x, y) = true
                        flashCount += 1

                        for each neighbor in GetNeighbors(width, height, x, y)
                            nextState(neighbor.x, neighbor.y) += 1
                        next
                    end if
                next
            next

        loop while newFlashOccurred


        for x = 0 to width - 1
            for y = 0 to height - 1
                if nextState(x, y) > 9 then nextState(x, y) = 0
            next
        next

        return (nextState, flashCount)
    end function

    sub Main(args as string())
        dim initialState = ReadInput()

        dim part1State = initialState
        dim flashes as integer = 0
        for currentStep = 1 to 100
            dim res = DeriveNextState(part1State)
            flashes += res.flashCount
            part1State = res.nextState
        next
        Console.WriteLine($"Number of flashed octopus after 100 steps; Part 1: {flashes}")

        dim part2State = initialState
        dim stepCount = 1
        while true
            dim res = DeriveNextState(part2State)
            part2State = res.nextState
            if res.flashCount = part2State.Length then exit while
            stepCount += 1
        end while
        Console.WriteLine($"Number of steps afer which the octopus synchronized; Part 2: {stepCount}")
    end sub
end module
