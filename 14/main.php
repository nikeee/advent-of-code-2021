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

// As expected, the naive solution didn't work out for larger numbers.
// We're being more clever because of otherwise exponential growth.
function apply_rules(array $rules, array $polymer_map, array $occurrences): array {
    // Applying a single rule always yields two new character pairs that need to be processed in the next step.
    // So we can just keep track of the pairs that should be present in our string. This suffices because we only need to know which pairs exist.
    // We don't know what the string looks like, but we know how many chars are in there.
    $next_polymer_map = [];
    foreach ($polymer_map as $pair => $count) {
        if ($count <= 0)
            continue;

            $char_to_insert_between = $rules[$pair];
        assert($char_to_insert_between);

        [$first, $second] = str_split($pair);

        $char_code = ord($char_to_insert_between);
        $occurrences[$char_code] = ($occurrences[$char_code] ?? 0) + $count;

        $resulting_first_pair = $first . $char_to_insert_between;
        $v = $next_polymer_map[$resulting_first_pair] ?? 0;
        $next_polymer_map[$resulting_first_pair] = $v + $count;

        $resulting_second_pair = $char_to_insert_between . $second;
        $v = $next_polymer_map[$resulting_second_pair] ?? 0;
        $next_polymer_map[$resulting_second_pair] = $v + $count;
    }

    return [$next_polymer_map, $occurrences];
}

function create_pair_map(string $polymer): array {
    $polymer_map = [];
    for ($i = 0; $i < strlen($polymer) - 1; ++$i) {
        $pair = $polymer[$i] . $polymer[$i + 1];
        $polymer_map[$pair] = ($polymer_map[$pair] ?? 0) + 1;
    }
    return $polymer_map;
}

$occurrences = count_chars($initial_polymer, 1);
$polymer_map = create_pair_map($initial_polymer);
for ($i = 0; $i < 10; ++$i) {
    [$polymer_map, $occurrences] = apply_rules($rules, $polymer_map, $occurrences);
}

$solution = max($occurrences) - min($occurrences);
echo "Length of polymer after 10 rounds; Part 1: $solution" . PHP_EOL;

$occurrences = count_chars($initial_polymer, 1);
$polymer_map = create_pair_map($initial_polymer);
for ($i = 0; $i < 40; ++$i) {
    [$polymer_map, $occurrences] = apply_rules($rules, $polymer_map, $occurrences);
}

$solution = max($occurrences) - min($occurrences);
echo "Length of polymer after 40 rounds; Part 1: $solution" . PHP_EOL;
