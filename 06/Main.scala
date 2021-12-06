// Run:
//     scala -deprecation Main.scala < input.txt

import scala.io.StdIn.readLine

object Day05 extends App {
    val fish = readLine()
        .split(",")
        .map(_.toInt)

    val ageMap = fish
        .groupBy(identity)
        .view.mapValues(_.size.toLong)
        .toMap

    val part1Distribution = (1 to 80).foldLeft(ageMap)((state, _) => processDay(state))
    val part1Solution = computeResult(part1Distribution)
    println(s"Number of fish after 80 days; Part 1: $part1Solution")

    val part2Distribution = (1 to 256).foldLeft(ageMap)((state, _) => processDay(state))
    val part2Solution = computeResult(part2Distribution)
    println(s"Number of fish after 256 days; Part 2: $part2Solution")


    def computeResult(currentData: Map[Int, Long]) : Long = currentData.values.foldLeft(0L)(_ + _)

    def processDay(currentData: Map[Int, Long]) : Map[Int, Long] = {
        val nextDataWithoutOverflow = (8 to 1 by -1)
                        .map(age => (age - 1 -> currentData.getOrElse(age, 0L)))
                        .toMap

        val overflowCount = currentData.getOrElse(0, 0L)
        val seven = currentData.getOrElse(7, 0L)

        nextDataWithoutOverflow ++ Map(
            (8 -> overflowCount),
            (6 -> (overflowCount + seven))
        )
    }
}
