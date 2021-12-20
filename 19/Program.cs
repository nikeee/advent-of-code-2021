// Compile:
//     dotnet build -c Release
// Run:
//     ./bin/Release/net6.0/19 < input.txt
// Version:
//     dotnet --version
//     6.0.101

using System.Runtime.InteropServices;

namespace Day19;

readonly struct Vector
{
    public readonly int X;
    public readonly int Y;
    public readonly int Z;
    public Vector(int x, int y, int z)
    {
        X = x;
        Y = y;
        Z = z;
    }
    public static Vector operator -(Vector a, Vector b) => new(a.X - b.X, a.Y - b.Y, a.Z - b.Z);
    public static Vector operator +(Vector a, Vector b) => new(a.X + b.X, a.Y + b.Y, a.Z + b.Z);
    public static int ManhattanDistance(Vector a, Vector b) => Math.Abs(a.X - b.X) + Math.Abs(a.Y - b.Y) + Math.Abs(a.Z - b.Z);
    public override string ToString() => $"{X},{Y},{Z}";
    // We don't need GetHashCode and Equals here, the defaults seem good enough:
    // https://devblogs.microsoft.com/premier-developer/performance-implications-of-default-struct-equality-in-c/
}

record Scanner(
    int Id,
    IReadOnlySet<Vector> Beacons,
    IReadOnlyDictionary<int, IReadOnlySet<Vector>> TransformedBeacons
);
record Match(
    Scanner Scanner,
    int TransformationId,
    Vector AbsolutePosition,
    IReadOnlySet<Vector> AbsoluteBeacons
);

class Program
{
    static void Main()
    {
        var lines = new List<string>();
        string? line;
        while ((line = Console.ReadLine()) != null)
            lines.Add(line);

        var input = lines
            .Select(l => l.Trim())
            .Where(l => !string.IsNullOrWhiteSpace(l));

        var scanners = ParseInput(input)
            .Select((beacons, index) => new Scanner(index, beacons, CreateBeaconTransformations(beacons)))
            .ToHashSet();

        var scanner0 = scanners.Where(s => s.Id == 0).First()!;
        scanners.Remove(scanner0);
        var matchedScanners = new HashSet<Match>
        {
            new Match(scanner0, 0, new Vector(), scanner0.Beacons),
        };

        while (scanners.Count > 0)
        {
            Match? matchToAdd = null;
            foreach (var candidate in scanners)
            {
                foreach (var match in matchedScanners)
                {
                    for (int transformationId = 0; transformationId < 24; ++transformationId)
                    {
                        // Core idea:
                        // If we've found the correct transformation,
                        // there are at least 12 points that are shifted by the same offset with respect to beacons of an aligned scanner
                        // Also, this offset will also be the position of the scanner with respect to the initial scanner

                        var offsetCounts = new Dictionary<Vector, int>();

                        var transformedBeacons = candidate.TransformedBeacons[transformationId];

                        foreach (var beaconCandidate in transformedBeacons)
                        {
                            foreach (var alignedBeacon in match.AbsoluteBeacons)
                            {
                                ++CollectionsMarshal.GetValueRefOrAddDefault(
                                    offsetCounts,
                                    (alignedBeacon - beaconCandidate),
                                    out var _
                                );
                            }
                        }

                        var mostUsedOffsetCount = offsetCounts.Values.Max();
                        if (mostUsedOffsetCount < 12)
                            continue;

                        // At this point, we have at least 12 beacons that are offset by the same vector.
                        // These are likely the ones that both scanners can see.

                        var offset = offsetCounts
                            .Where(e => e.Value == mostUsedOffsetCount)
                            .Select(e => e.Key)
                            .First();

                        var alignedCoordinates = transformedBeacons.Select(b => offset + b).ToHashSet();

                        matchToAdd = new Match(candidate, transformationId, offset, alignedCoordinates);
                        break;
                    }

                    if (matchToAdd != null)
                        break;
                }
                if (matchToAdd != null)
                    break;
            }

            if (matchToAdd != null)
            {
                matchedScanners.Add(matchToAdd);
                scanners.Remove(matchToAdd.Scanner);
            }
        }

        var allBeacons = matchedScanners.SelectMany(m => m.AbsoluteBeacons).ToHashSet();
        Console.WriteLine($"Number of beacons on the entire map; Part 1: {allBeacons.Count}");

        // Luckily, the LINQ syntax offers an easy way of doing a cartesian product! :)
        var distancesBetweenScanners = from scannerA in matchedScanners
                                       from scannerB in matchedScanners
                                       select Vector.ManhattanDistance(scannerA.AbsolutePosition, scannerB.AbsolutePosition);
        Console.WriteLine($"Largest distance between two scanners; Part 2: {distancesBetweenScanners.Max()}");
    }

    private static IReadOnlyDictionary<int, IReadOnlySet<Vector>> CreateBeaconTransformations(IReadOnlySet<Vector> beacons)
    {
        var res = new Dictionary<int, IReadOnlySet<Vector>>();
        for (int transformationId = 0; transformationId < 24; ++transformationId)
            res[transformationId] = beacons.Select(v => TransformVector(v, transformationId)).ToHashSet();
        return res;
    }

    static Vector TransformVector(Vector v, int transformationId)
    {
        // Each rotation corresponds to a rotation matrix in this overview:
        // https://www.euclideanspace.com/maths/algebra/matrix/transforms/examples/index.htm
        // We identify the column swapping/negation using mod/div

        var (negation, swap) = Math.DivRem(transformationId, 4);
        Vector res = negation switch
        {
            0 => new(v.X, v.Y, v.Z),
            1 => new(-v.X, v.Y, -v.Z),
            2 => new(v.Z, v.Y, -v.X),
            3 => new(-v.Z, v.Y, v.X),
            4 => new(v.X, v.Z, -v.Y),
            5 => new(v.X, -v.Z, v.Y),
            _ => throw new ArgumentOutOfRangeException(nameof(transformationId)),
        };

        return swap switch
        {
            0 => new(res.X, res.Y, res.Z),
            1 => new(-res.Y, res.X, res.Z),
            2 => new(-res.X, -res.Y, res.Z),
            3 => new(res.Y, -res.X, res.Z),
            _ => throw new ArgumentOutOfRangeException(nameof(transformationId)),
        };
    }

    private static IReadOnlyList<IReadOnlySet<Vector>> ParseInput(IEnumerable<string> input)
    {
        var scannerData = new List<IReadOnlySet<Vector>>();

        // This could probably be also done using some fancy TakeWhile/LINQ method ¯\_(ツ)_/¯
        var currentScannerData = new HashSet<Vector>();
        foreach (var scannerLine in input)
        {
            if (scannerLine.StartsWith("---"))
            {
                if (currentScannerData.Count > 0)
                {
                    scannerData.Add(currentScannerData);
                    currentScannerData = new HashSet<Vector>();
                }
                continue;
            }

            var coordinates = scannerLine.Split(",");
            currentScannerData.Add(new Vector(
                int.Parse(coordinates[0]),
                int.Parse(coordinates[1]),
                int.Parse(coordinates[2])
            ));
        }
        if (currentScannerData.Count > 0)
            scannerData.Add(currentScannerData);

        return scannerData;
    }
}
