// Run:
//     scala -deprecation Main.scala < input.txt

import scala.io.StdIn.readLine

object Day05 extends App {
    val fish = readLine()
        .split(",")
        .map(_.toInt)

    val ageMap = fish
        .groupBy(identity)
        .view.mapValues(_.size)
        .toMap

    val part1Distribution = (1 to 80).foldLeft(ageMap)((state, _) => processDay(state))
    val part1Solution = computeResult(part1Distribution)
    println(s"Number of fish after 80 days; Part 1: $part1Solution")


    def computeResult(currentData: Map[Int, Int]) : Int = currentData.values.foldLeft(0)(_ + _)

    def processDay(currentData: Map[Int, Int]) : Map[Int, Int] = {
        val nextDataWithoutOverflow = (8 to 1 by -1)
                        .map(age => (age - 1 -> currentData.getOrElse(age, 0)))
                        .toMap

        val overflowCount = currentData.getOrElse(0, 0)
        val seven = currentData.getOrElse(7, 0)

        nextDataWithoutOverflow ++ Map(
            (8 -> overflowCount),
            (6 -> (overflowCount + seven))
        )
    }
}
