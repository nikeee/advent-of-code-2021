// Run:
//     haxe --main Main --interp < input.txt
// Compiler/Runtime version:
//     haxe --version
//     4.2.4

using Std;
using Lambda;
using StringTools;
using haxe.ds.IntMap;

class Point {
  public var x:Int;
  public var y:Int;

  public function new(x:Int, y:Int) {
    this.x = x;
    this.y = y;
  }

  public function hashCode():Int return x + (y * 1000);
  public function equals(other:Point) return this.x == other.x && this.y ==  other.y;
  public function toString() return '($x, $y)';
  public static function parse(value:String):Point {
    var split = value.split(",");
    return new Point(
      Std.parseInt(split[0].trim()),
      Std.parseInt(split[1].trim())
    );
  }
}

class Line {
  public var start:Point;
  public var end:Point;

  public function new(start:Point, end:Point) {
    this.start = start;
    this.end = end;
  }
  public function isHorizontalOrVertical() return start.x == end.x || start.y == end.y;
  public function toString() return '$start -> $end';
  public static function parse(value:String):Line {
    var split = value.split("->");
    return new Line(
      Point.parse(split[0].trim()),
      Point.parse(split[1].trim())
    );
  }
}

class Main {
  static public function main():Void {
    var input = Sys.stdin().readAll().toString().trim().split("\n");
    var lines = input.map(Line.parse);

    var part1Lines = lines.filter(l -> l.isHorizontalOrVertical());
    var part1Map = new IntMap<IntMap<Int>>();
    for(line in part1Lines) {
      drawLine(part1Map, line);
    }

    var part1 = countOverlaps(part1Map);
    Sys.println('Number of overlapping horizontal and vertical lines; Part 1: $part1');

    var part2Map = new IntMap<IntMap<Int>>();
    for(line in lines) {
      drawLine(part2Map, line);
    }

    var part2 = countOverlaps(part2Map);
    Sys.println('Number of overlapping lines; Part 2: $part2');
  }

  static function drawLine(map:IntMap<IntMap<Int>>, line:Line):Void {
    var leftPoint = line.start.x < line.end.x
      ? line.start
      : line.end;

    var rightPoint = line.start.x < line.end.x
      ? line.end
      : line.start;

    // Because the lines are always in 45° angles, the increment must always be one of {-1, 0, 1}
    // -> We can just use the sign of the delta of left and right
    var xIncrement = sign(leftPoint.x - rightPoint.x);
    var yIncrement = sign(leftPoint.y - rightPoint.y);

    var currentPoint = leftPoint;
    while(!currentPoint.equals(rightPoint)) {
      visitPoint(map, currentPoint);
      currentPoint = new Point(
        currentPoint.x + xIncrement,
        currentPoint.y + yIncrement
      );
    }
    visitPoint(map, rightPoint);
  }

  static function visitPoint(map:IntMap<IntMap<Int>>, p:Point):Void {
    var column = map.get(p.x);
    if (column == null) {
      column = new IntMap<Int>();
    }
    var count = column.get(p.y);
    if (count == null) {
      count = 0;
    }
    column.set(p.y, count + 1);
    map.set(p.x, column);
  }

  static function countOverlaps(map:IntMap<IntMap<Int>>):Int {
    var overlaps = 0;
    for(column in map) {
      for(field in column) {
        if (field > 1) {
          ++overlaps;
        }
      }
    }
    return overlaps;
  }

  // Math.max/min/sign only exists for Float, so we need to roll our own
  static function maxInt(a:Int, b:Int): Int return a > b ? a : b;
  static function minInt(a:Int, b:Int): Int return a < b ? a : b;
  static function sign(a:Int): Int return a == 0 ? 0: (a < 0 ? 1 : -1);
}
