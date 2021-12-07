#!/usr/bin/env Rscript
printf <- function(...) invisible(cat(sprintf(...)))

crabPositions <- scan(file="stdin", sep=",", quiet=TRUE)

targetPosition <- median(crabPositions)
totalFuelCost <- sum(abs(crabPositions - targetPosition))
printf("Total amount of fuel needed to align crabs; Part 1: %d\n", totalFuelCost)
