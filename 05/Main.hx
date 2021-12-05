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
  }

  static function drawLine(map:IntMap<IntMap<Int>>, line:Line):Void {
    if (line.start.x == line.end.x) {
        var start = minInt(line.start.y, line.end.y);
        var end = maxInt(line.start.y, line.end.y);

        for(y in (start...end + 1)) {
          var p = new Point(line.start.x, y);
          visitPoint(map, p);
        }
    } else if (line.start.y == line.end.y) {
        var start = minInt(line.start.x, line.end.x);
        var end = maxInt(line.start.x, line.end.x);

        for(x in (start...end + 1)) {
          var p = new Point(x, line.start.y);
          visitPoint(map, p);
        }
    }
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

  // Math.max/min only exists for Float, so we need to roll our own
  static function maxInt(a:Int, b:Int): Int return a > b ? a : b;
  static function minInt(a:Int, b:Int): Int return a < b ? a : b;
}
