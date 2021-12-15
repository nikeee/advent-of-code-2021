// Compile:
//     dart compile exe --sound-null-safety main.dart
// Run:
//     ./main.exe < input.txt

import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:collection';

void main(List<String> arguments) async {
  var cave = await stdin
    .transform(utf8.decoder)
    .transform(const LineSplitter())
    .map((l) => l.split('').map(int.parse).toList())
    .toList();

  var height = cave.length;
  var width = cave[0].length;

  var start = new Point(0, 0);
  var endPart1 = new Point(width - 1, height - 1);
  var cheapestPathCostPart1 = findCheapestPathCost(cave, width, height, start, endPart1);
  print('Risk of the path with the lowest risk; Part 1: $cheapestPathCostPart1');

  var part2Scaling = 5;
  var part2Cave = exploreCave(cave, width, height, part2Scaling);
  var part2Width = width * part2Scaling;
  var part2Height = height * part2Scaling;

  var endPart2 = new Point(part2Width - 1, part2Height - 1);
  var cheapestPathCostPart2 = findCheapestPathCost(part2Cave, part2Width, part2Height, start, endPart2);
  print('Risk of the path with the lowest risk in larger cave; Part 2: $cheapestPathCostPart2');
}

List<List<int>> exploreCave(List<List<int>> grid, int width, int height, [int scaleFactor = 5]) {
  var largerGrid = List<List<int>>.empty(growable: true);

  for (int y = 0; y < height * 5; ++y) {
    var yInFirstTile = y % height;
    var row = List<int>.filled(width * scaleFactor, -1);
    largerGrid.add(row);

    for (int x = 0; x < width * 5; ++x) {
      var xInFirstTile = x % width;
      var fileValueOffset = (x ~/ width) + (y ~/ height);

      var originalValue = grid[yInFirstTile][xInFirstTile] - 1;
      var thisValue = originalValue + fileValueOffset;
      thisValue %= 9;
      thisValue += 1;
      largerGrid[y][x] = thisValue;
    }
  }

  return largerGrid;
}

Iterable<Point> getNeighbors(Point pos, int width, int height) sync* {
  if (pos.x > 0) yield new Point(pos.x - 1, pos.y);
  if (pos.x < width - 1) yield new Point(pos.x + 1, pos.y);
  if (pos.y > 0) yield new Point(pos.x, pos.y - 1);
  if (pos.y < height - 1) yield new Point(pos.x, pos.y + 1);
}

int heuristic(Point a, Point b) {
  var x = a.x - b.x;
  var y = a.y - b.y;
  return sqrt(x * x + y * y).toInt();
}

// The problem basically demands an implementation of A*
// However, as we are only interested in the cost to get to the final point, we don't need the reference to the cheapest parent
int? findCheapestPathCost(List<List<int>> grid, int width, int height, Point start, Point target) {
  var openList = new HashSet<Point>();
  openList.add(start);

  var closeList = new HashSet<Point>();

  var distances = new HashMap<Point, int>(); // "g"
  distances[start] = 0;

  while (openList.length > 0) {

    Point? currentNode = null;

    for (final p in openList) {
      // The openList should actually be a priority queue, but that would require a separate package
      if (
        currentNode == null ||
        (distances[p]! + heuristic(p, target) < distances[currentNode]! + heuristic(currentNode, target))
      ) {
        currentNode = p;
      }
    }

    if (currentNode == null) {
      return null;
    }

    if (currentNode == target) {
      return distances[target];
    }

    for (final neighbor in getNeighbors(currentNode, width, height)) {
      var weight = grid[neighbor.y][neighbor.x];

      if (!openList.contains(neighbor) && !closeList.contains(neighbor)) {

        openList.add(neighbor);
        distances[neighbor] = distances[currentNode]! + weight;

      } else if (distances[neighbor]! > (distances[currentNode]! + weight)) {

        distances[neighbor] = distances[currentNode]! + weight;

        if (closeList.contains(neighbor)) {
          closeList.remove(neighbor);
          openList.add(neighbor);
        }
      }
    }

    closeList.add(currentNode);
    openList.remove(currentNode);
  }
  return null;
}

class Point {
  final int x;
  final int y;
  const Point(this.x, this.y);

  bool operator ==(o) => o is Point && x == o.x && y == o.y;
  int get hashCode => Object.hash(x, y);
  String toString() => '(' + x.toString() + ', ' + y.toString() + ')';
}

// Function used only for debugging
void printGrid(List<List<int>> grid, int width, int height) {
  for (int y = 0; y < height; ++y) {
    for (int x = 0; x < width; ++x) {
      stdout.write(grid[y][x]);
    }
    print('');
  }
}
