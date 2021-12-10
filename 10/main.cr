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
        return next_char
      end

      opening_char = stack.pop()
      if !PAIRS.includes?({opening_char, next_char})
        return next_char
      end

    else
      stack.push(next_char)
    end

    offset += 1
  end
  return nil
end

syntax_score = lines
  .map {|line| get_corrupt_char(line)}
  .select {|c| c != nil}
  .map {|c| SYNTAX_SCORE_MAP[c]}
  .sum(0)

puts "Syntax error score; Part 1: #{syntax_score}"
