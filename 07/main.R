#!/usr/bin/env Rscript

# Usage:
#     ./main.R < input.txt

if (!require("purrr")) {
    # Sadly, we need this package for map_int() (it isn't shipped with the stdlib of R)
    install.packages("purrr")
}
library("purrr")

printf <- function(...) invisible(cat(sprintf(...)))

crabPositions <- scan(file="stdin", sep=",", quiet=TRUE)

targetPositionPart1 <- median(crabPositions)
totalFuelCostPart1 <- sum(abs(crabPositions - targetPositionPart1))
printf("Total amount of fuel needed to align crabs; Part 1: %d\n", totalFuelCostPart1)


# Shorthand function to compute sum(1:n)
sumUntil <- function(n) as.integer((n * (n + 1)) / 2)

computeFuelForTarget <- function(positions, targetPosition) sum(sumUntil(abs(positions - targetPosition)))

positionRange = min(crabPositions):max(crabPositions)
fuelCostsForEveryPosition <- map_int(positionRange, ~ computeFuelForTarget(crabPositions, .x))
totalFuelCostPart2 <- min(fuelCostsForEveryPosition)

printf("Total amount of fuel needed to align crabs (advanced crab engineering); Part 2: %d\n", totalFuelCostPart2)
