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
  var end = new Point(width - 1, height - 1);
  var cheapestPathCost = findCheapestPathCost(cave, width, height, start, end);
  print('Risk of the path with the lowest risk; Part 1: $cheapestPathCost');
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
