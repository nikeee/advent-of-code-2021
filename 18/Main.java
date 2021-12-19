// Compile:
//     javac Main.java
// Use:
//     java -ea Main < input.txt
// Version used:
//     javac --version
//     javac 17.0.1

import java.util.LinkedList;
import java.util.List;
import java.util.Optional;
import java.util.Scanner;

public class Main {
  public static void main(String[] args) {
    var lines = new LinkedList<String>();
    try (var scanner = new Scanner(System.in)) {
      while (scanner.hasNextLine()) {
        lines.add(scanner.nextLine());
      }
    }

    Node result = null;
    for (Node number : parseInput(lines)) {
      result = result == null
        ? number
        : addNumbers(result, number);
    }
    if (result == null) {
      System.out.println("Magnitude of the final sum; Part 1: <no input>");
    } else {
      System.out.println("Magnitude of the final sum; Part 1: " + result.getMagnitude());
    }

    int highestMagnitude = -1;
    for (List<String> pair : cartesianProduct(lines)) {
      var first = parseNumber(pair.get(0));
      var second = parseNumber(pair.get(1));
      var sum = addNumbers(first, second);
      var magnitude = sum.getMagnitude();
      if (magnitude > highestMagnitude)
        highestMagnitude = magnitude;
    }
    System.out.println("Highest magnitude that can be created with two numbers; Part 2: " + highestMagnitude);
  }

  /** Since the operation potentially mutate numbers, we need to re-parse the entire input again. */
  static List<Node> parseInput(List<String> lines) {
    return lines.stream()
      .map(Main::parseNumber)
      .toList();
  }

  static Node parseNumber(String line) {
    var n = parseNumber(line, 0).value();
    bindNode(n, null);
    return n;
  }

  static ParseResult<Node> parseNumber(String value, int offset) {
    if (value.charAt(offset) == '[') {
      ++offset;
      Node left;
      if (value.charAt(offset) == '[') {
        var leftResult = parseNumber(value, offset);
        left = leftResult.value();
        offset = leftResult.offset();
      } else {
        left = new RegularNumber(Integer.parseInt(Character.toString(value.charAt(offset))));
        ++offset;
      }

      assert value.charAt(offset) == ',';
      ++offset;

      Node right;
      if (value.charAt(offset) == '[') {
        var rightResult = parseNumber(value, offset);
        right = rightResult.value();
        offset = rightResult.offset();
      } else {
        right = new RegularNumber(Integer.parseInt(Character.toString(value.charAt(offset))));
        ++offset;
      }

      assert value.charAt(offset) == ']';
      ++offset;

      return new ParseResult<>(new PairNumber(left, right), offset);
    }
    var n = new RegularNumber(Integer.parseInt(Character.toString(value.charAt(offset))));
    ++offset;
    return new ParseResult<>(n, offset);
  }

  static void bindNode(Node n, PairNumber parent) {
    n.parent = parent;
    if (n instanceof PairNumber pn) {
      bindNode(pn.left, pn);
      bindNode(pn.right, pn);
    }
  }

  /** This is a nightmare of side effects :( */
  static Node addNumbers(Node a, Node b) {
    var intermediateNumber = new PairNumber(a, b);
    a.parent = intermediateNumber;
    b.parent = intermediateNumber;
    intermediateNumber.reduce();
    return intermediateNumber;
  }

  /** Joins a list to itself. */
  static <A> List<List<A>> cartesianProduct(List<A> values) {
    return values.stream()
      .map(e1 ->
        values.stream()
          .map(e2 -> List.of(e1, e2))
          .toList()
      )
      .flatMap(List::stream)
      .toList();
  }
}

abstract sealed class Node permits RegularNumber, PairNumber {
  PairNumber parent;

  abstract int getMagnitude();

  abstract Optional<Node> findNested(int level);

  Optional<RegularNumber> findLeftestGreaterThan(int n) {
    if (this instanceof RegularNumber rn) {
      return rn.value > n ? Optional.of(rn) : Optional.empty();
    }

    var res = Optional.<RegularNumber>empty();
    if (((PairNumber) this).left instanceof RegularNumber rn && rn.value > n) {
      res = Optional.of(rn);
    }
    if (((PairNumber) this).left instanceof PairNumber pn) {
      res = pn.findLeftestGreaterThan(n);
    }

    if (res.isEmpty()) {
      if (((PairNumber) this).right instanceof RegularNumber rn && rn.value > n) {
        res = Optional.of(rn);
      }
      if (((PairNumber) this).right instanceof PairNumber pn) {
        res = pn.findLeftestGreaterThan(n);
      }
    }
    return res;
  }

  Optional<RegularNumber> findRegularNumberToLeft() {
    if (parent == null)
      return Optional.empty();
    if (this == parent.left)
      return parent.findRegularNumberToLeft();
    var x = parent.left;
    while (!(x instanceof RegularNumber))
      x = ((PairNumber) x).right;
    return Optional.of((RegularNumber) x);
  }

  Optional<RegularNumber> findRegularNumberToRight() {
    if (parent == null)
      return Optional.empty();
    if (this == parent.right)
      return parent.findRegularNumberToRight();
    var x = parent.right;
    while (!(x instanceof RegularNumber))
      x = ((PairNumber) x).left;
    return Optional.of((RegularNumber) x);
  }

  void reduce() {
    while (true) {
      var nestedNumber = findNested(4);
      if (nestedNumber.isPresent()) {
        ((PairNumber) nestedNumber.get()).explode();
        continue;
      }
      var splitCandidate = findLeftestGreaterThan(9);
      if (splitCandidate.isPresent()) {
        splitCandidate.get().split();
        continue;
      }
      return;
    }
  }

  static void replaceNode(Node oldNode, Node newNode) {
    newNode.parent = oldNode.parent;
    if (oldNode.parent.left == oldNode) {
      oldNode.parent.left = newNode;
    } else if (oldNode.parent.right == oldNode) {
      oldNode.parent.right = newNode;
    }
    oldNode.parent = null;
  }
}

final class RegularNumber extends Node {
  int value;

  RegularNumber(int value) {
    this.value = value;
  }

  @Override
  int getMagnitude() {
    return value;
  }

  @Override
  Optional<Node> findNested(int level) {
    return level == 0 ? Optional.of(this) : Optional.empty();
  }

  void split() {
    var a = new RegularNumber((int) Math.floor(value / 2.0f));
    var b = new RegularNumber((int) Math.ceil(value / 2.0f));
    var newNumber = new PairNumber(a, b);
    a.parent = newNumber;
    b.parent = newNumber;

    replaceNode(this, newNumber);
  }

  @Override
  public String toString() {
    return Integer.toString(value);
  }
}

final class PairNumber extends Node {
  Node left;
  Node right;

  PairNumber(Node left, Node right) {
    this.left = left;
    this.right = right;
  }

  @Override
  int getMagnitude() {
    var leftMagnitude = 3 * left.getMagnitude();
    var rightMagnitude = 2 * right.getMagnitude();
    return leftMagnitude + rightMagnitude;
  }

  void explode() {
    var numberToLeft = findRegularNumberToLeft();
    var numberToRight = findRegularNumberToRight();

    numberToLeft.ifPresent(n -> n.value += ((RegularNumber) left).value);
    numberToRight.ifPresent(n -> n.value += ((RegularNumber) right).value);

    var newNode = new RegularNumber(0);
    replaceNode(this, newNode);
  }

  @Override
  Optional<Node> findNested(int level) {
    if (level == 0) {
      return Optional.of(this);
    }

    var res = Optional.<Node>empty();
    if (this.left instanceof PairNumber pn) {
      res = pn.findNested(level - 1);
    }
    if (res.isEmpty() && (this.right instanceof PairNumber pn)) {
      res = pn.findNested(level - 1);
    }
    return res;
  }

  @Override
  public String toString() {
    return "[" + left + "," + right + "]";
  }
}

record ParseResult<T>(T value, int offset) { }
