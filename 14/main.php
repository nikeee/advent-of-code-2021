#!/usr/bin/env php
<?php
// Use:
//     ./main.php < input.txt
// Runtime version:
//     php --version
//     PHP 8.1.0 (cli) (built: Dec  2 2021 12:11:39) (NTS)

$initial_polymer = @trim(fgets(STDIN));

$lines = [];
while (($line = fgets(STDIN)) !== false)
    $lines[] = trim($line);

$lines = array_filter($lines, fn($l) => strlen($l) > 0);

$rules_arr = array_map(fn($line) => explode(' -> ', $line), $lines);

$rules = [];
foreach ($rules_arr as $rule) {
    [$chars, $center] = $rule;
    $rules[$chars] = $center;
}

// We're doing the naiive version for the first part
function apply_rules($rules, $polymer) {
    $result_str = '';
    $len = strlen($polymer) - 1;
    for ($i = 0; $i < $len; ++$i) {
        $pair = $polymer[$i] . $polymer[$i + 1];
        $insertion = $rules[$pair];
        assert($insertion);
        $result_str .= $polymer[$i] . $insertion;
    }

    return $result_str . $polymer[-1];
}

$polymer = $initial_polymer;
for ($i = 0; $i < 10; ++$i)
    $polymer = apply_rules($rules, $polymer);

$char_frequencies = count_chars($polymer, 1);

$solution = max($char_frequencies) - min($char_frequencies);
echo "Part 1: $solution" . PHP_EOL;
