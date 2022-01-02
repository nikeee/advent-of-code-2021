// Compile:
//     kotlinc Main.kt -include-runtime -d Main.jar
// Run:
//     java -jar Main.jar < input.txt
// Version:
//     kotlinc -version
//     info: kotlinc-jvm 1.6.0 (JRE 11.0.13+8-Ubuntu-0ubuntu1.21.10)

import java.util.*
import kotlin.math.pow

fun main() {
    val input = generateSequence(::readLine).joinToString("\n")
    val initialStatePart1 = parseMap(input)

    val minFinalStateCostPart1 = findFinalState(initialStatePart1.second, initialStatePart1.third, mutableMapOf(), Int.MAX_VALUE)
    println("Least energy required to move amphipods to correct position; Part 1: $minFinalStateCostPart1")

    val part2Addition = listOf("  #D#C#B#A#", "  #D#B#A#C#")

    val lines = input.split("\n")
    val inputPart2Arr = lines.slice(0..2) + part2Addition + lines.slice(3..lines.size - 1)
    val inputPart2 = inputPart2Arr.joinToString(separator = "\n")
    val initialStatePart2 = parseMap(inputPart2)

    val minFinalStateCostPart2 = findFinalState(initialStatePart2.second, initialStatePart2.third, mutableMapOf(), Int.MAX_VALUE)
    println("Least energy required to move amphipods to correct position with larger map; Part 2: $minFinalStateCostPart2")
}

data class StateTask(
    val priority: Int,
    val state: Set<Amphipod>,
    val moves: Int,
    val cost: Int,
)

fun findFinalState(
    initialState: Set<Amphipod>,
    homes: List<List<Node>>,
    visitedStates: MutableMap<Set<Amphipod>, Int>,
    maxFinalStateCost: Int
): Int {
    val stateQueue = PriorityQueue(Comparator.comparing(StateTask::priority))

    for ((nextState, movingCost) in possibleNextStates(initialState)) {
        stateQueue.add(
            StateTask(
                getStatePriority(nextState, homes),
                nextState,
                1,
                movingCost,
            )
        )
    }

    var maxFinalStateCostLocal = maxFinalStateCost

    // If we find a final state, this is the upper bound for other final states
    // Helps to reduce the search space once anything was found

    while (stateQueue.isNotEmpty()) {
        val (_, state, moves, cost) = stateQueue.remove()

        if (cost > maxFinalStateCostLocal)
            continue

        // This check could be made simpler :S
        val previousVisitedStateCost = visitedStates[state]
        if (previousVisitedStateCost != null) {
            if (previousVisitedStateCost > cost)
                visitedStates[state] = cost
            else
                continue // We already checked that state and got there cheaper
        } else {
            visitedStates[state] = cost
        }

        if (isFinalState(state)) {
            if (cost < maxFinalStateCostLocal) {
                maxFinalStateCostLocal = findFinalState(initialState, homes, visitedStates, cost)
            }
            continue
        }

        for ((nextState, movingCost) in possibleNextStates(state)) {

            val prevCosts = visitedStates[nextState]
            if (prevCosts != null && prevCosts > maxFinalStateCost)
                continue

            stateQueue.add(
                StateTask(
                    getStatePriority(nextState, homes) * moves,
                    nextState,
                    moves + 1,
                    cost + movingCost,
                )
            )
        }
    }

    return maxFinalStateCostLocal
}

fun possibleNextStates(state: Set<Amphipod>) = sequence {
    for (amp in state) {
        // Rule 3: They cannot move if they are on a hallway and cannot move home
        if (amp.isOnHallway && !amp.canMoveHome(state))
            continue

        val otherAmps = state.filter { it != amp }.toSet()
        for ((movedAmp, moveCost) in getPossibleTargetPoints(amp, state)) {
            val newState = otherAmps.plusElement(movedAmp)
            yield(Pair(newState, moveCost))
        }
    }
}

fun getPossibleTargetPoints(amphipod: Amphipod, state: Set<Amphipod>) = sequence {
    // If an amphipod is in the bottom of his cave, don't do anything with it
    // This is just a cheap optimization and could be omitted
    if (amphipod.isInCorrectRoom && amphipod.location.neighbors.size == 1)
        return@sequence

    val possiblePaths = getPaths(listOf(), state, amphipod.location)
    for (path in possiblePaths) {
        val lastNode = path.last()
        if (amphipod.isOnHallway && !lastNode.isCavePlace)
            continue

        if (lastNode.isCavePlace) {
            if (!amphipod.destinationRoom.contains(lastNode) || amphipod.hasForeignAmphipodsInHome(state))
                continue
        }
        val cost = path.size * amphipod.color.movingCost
        yield(
            Pair(amphipod.copy(location = lastNode), cost)
        )
    }
}

fun getPaths(prevNodes: List<Node>, state: Set<Amphipod>, start: Node): Sequence<List<Node>> = sequence {
    for (n in start.neighbors) {
        if (prevNodes.contains(n) || n.isOccupied(state))
            continue

        val newPrefix = prevNodes.plusElement(n)
        // Don't stop at nodes that are in front of an entrance
        if (n.canBeStoppedAt)
            yield(newPrefix)
        yieldAll(getPaths(newPrefix, state, n))
    }
}

fun getStatePriority(state: Set<Amphipod>, homes: List<List<Node>>): Int {
    val totalHomesForEachColor = homes[0].size
    // Create the sum of total possible regressions:
    // (10**2 + 10**1) * 4
    val worstPriority = homes.size * (1..totalHomesForEachColor).sumOf { (10f).pow(it).toInt() }
    var result = worstPriority

    // Basically, we subtract more if more correct amphipods are in their cave
    // However, if an amphiod is in his right cave, but there is an amphipod below him, this state is basically worthless. So there is a hard penalty for this kind of stuff
    for (homeColumn in homes) {
        for ((rowIndex, node) in homeColumn.withIndex()) {
            val occupant = node.getOccupant(state) ?: continue

            if (occupant.isInCorrectRoom) {
                result -= (10f).pow(rowIndex + 1).toInt()
            } else if (rowIndex > 0) {
                result += (10f).pow(rowIndex + 1 + 1).toInt()
            }
        }
    }

    return result
}

fun isFinalState(state: Set<Amphipod>) = state.all { it.isInCorrectRoom }

fun parseMap(input: String): Triple<Set<Node>, Set<Amphipod>, List<List<Node>>> {
    // As we're working with Node-class-based data structures, we need to create a data model from the input
    // This is done through this ugly "parsing" mechanism
    // Sadly, kotlin doesn't support named tuple types, so we must use "Triple"/"Pair" for that :(

    // Wire up the constant nodes
    val hall = (0..10)
        .map { Node(it == 0 || it == 10 || (it % 2) != 0, false, mutableListOf()) }
        .toList()

    for ((index, cell) in hall.withIndex()) {
        if (index > 0) {
            cell.neighbors.add(hall[index - 1])
        }
        if (index < hall.size - 1) {
            cell.neighbors.add(hall[index + 1])
        }
    }

    val homeLines = input.trim()
        .split("\n")
        .filter { it.contains("A|B|C|D".toRegex()) }
        .toList()

    val ampPattern = "#(\\w)".toRegex(RegexOption.IGNORE_CASE)

    val homeRows = mutableListOf<List<Node>>()

    val allAmps = mutableListOf<Amphipod>()
    for (row in homeLines) {
        val rowNodes = listOf(
            Node(true, true, mutableListOf()),
            Node(true, true, mutableListOf()),
            Node(true, true, mutableListOf()),
            Node(true, true, mutableListOf()),
        )
        homeRows.add(rowNodes)

        if (homeRows.size == 1) {
            rowNodes.forEachIndexed { i, node ->
                node.neighbors.add(hall[i * 2 + 2])
                hall[i * 2 + 2].neighbors.add(node)
            }
        } else {
            val previousAddedRow = homeRows[homeRows.size - 2]
            previousAddedRow.forEachIndexed { i, n ->
                rowNodes[i].neighbors.add(n)
                n.neighbors.add(rowNodes[i])
            }
        }

        ampPattern.findAll(row)
            .filter { it.groupValues.isNotEmpty() }
            .map { it.groupValues[1] }
            .mapIndexed { index, it -> Amphipod(Color.valueOf(it), rowNodes[index], mutableListOf()) }
            .forEach { allAmps.add(it) }
    }
    val homedAmps = allAmps.map { it.copy(destinationRoom = homeRows.map { row -> row[it.color.ordinal] }) }

    val homes = Color.values().map { c -> homeRows.map { it[c.ordinal] } }.toList()

    val allNodes = homeRows.flatten().toSet().plus(hall)
    return Triple(allNodes, homedAmps.toSet(), homes)
}

class Node(
    val canBeStoppedAt: Boolean,
    val isCavePlace: Boolean,
    val neighbors: MutableList<Node>,
) {
    fun getOccupant(state: Set<Amphipod>): Amphipod? = state.firstOrNull { it.location == this }
    fun isOccupied(state: Set<Amphipod>) = getOccupant(state) != null
}

data class Amphipod(
    val color: Color,
    val location: Node,
    val destinationRoom: List<Node>,
) {
    val isInCorrectRoom: Boolean
        get() = location in destinationRoom
    val isOnHallway: Boolean
        get() = !location.isCavePlace

    fun canMoveHome(fromState: Set<Amphipod>): Boolean {
        return !hasForeignAmphipodsInHome(fromState) && destinationRoom.any {
            !it.isOccupied(fromState) && canReachNode(
                fromState,
                location,
                it,
                setOf(),
            )
        }
    }

    fun hasForeignAmphipodsInHome(state: Set<Amphipod>) =
        destinationRoom
            .map { it.getOccupant(state) }
            .any { it != null && it.color != color }

    private fun canReachNode(state: Set<Amphipod>, source: Node, dest: Node, visitedNodes: Set<Node>): Boolean {
        return source == dest || source.neighbors.any {
            !visitedNodes.contains(it) && !it.isOccupied(state) && canReachNode(
                state, it, dest, visitedNodes.plusElement(it),
            )
        }
    }
}

enum class Color(val movingCost: Int) {
    A(1),
    B(10),
    C(100),
    D(1000),
}
