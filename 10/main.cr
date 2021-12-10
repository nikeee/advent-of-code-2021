# Compile:
#     crystal build --release main.cr
# Use:
#     ./main < input.txt
# Compiler version:
#     crystal --version
#     Crystal 1.2.2 [6529d725a] (2021-11-10)

lines = STDIN.gets_to_end.strip('\n').split('\n')

SYNTAX_SCORE_MAP = {
  ')' => 3,
  ']' => 57,
  '}' => 1197,
  '>' => 25137,
}

PAIRS = Set{
  {'(', ')'},
  {'[', ']'},
  {'{', '}'},
  {'<', '>'},
}

def get_corrupt_char(line : String)
  stack = [] of Char
  offset = 0
  while offset < line.size
    next_char = line[offset]
    if SYNTAX_SCORE_MAP.keys.includes?(next_char)

      if stack.size == 0
        return {next_char, stack}
      end

      opening_char = stack.pop()
      if !PAIRS.includes?({opening_char, next_char})
        return {next_char, stack}
      end

    else
      stack.push(next_char)
    end

    offset += 1
  end
  return {nil, stack}
end

syntax_score = lines
  .map {|line| get_corrupt_char(line)}
  .map {|c| c[0]}
  .select {|c| c != nil}
  .map {|c| SYNTAX_SCORE_MAP[c]}
  .sum(0)

puts "Syntax error score; Part 1: #{syntax_score}"

def median(arr)
  sorted_array = arr.sort
  center = (sorted_array.size / 2).round.to_i
  return sorted_array[center]
end

COMPLETION_SCORE = {
  '(' => 1,
  '[' => 2,
  '{' => 3,
  '<' => 4,
}

completion_scores = lines
  .map {|line| get_corrupt_char(line)}
  .select {|c| c[0] == nil}
  .map {|c| c[1].reverse }
  .map {|c| c.reduce(Int64.new(0)) { |acc, i| (acc * 5) + COMPLETION_SCORE[i] }}

puts "Syntax completion score; Part 1: #{median(completion_scores)}"
