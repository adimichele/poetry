#!/usr/bin/env ruby
require './env'

# FORMAT = ".*.*.*.*A/.*.*.*.*B/.*.*.*.*A/.*.*.*.*B"
# FORMAT = "*.*.*.*.A/*.*.*.*.A/*.*.*.*B/*.*.*.*.A/*.*.*.*.A/*.*.*.*B"
# FORMAT = ".*..*..*.A/.*..*..*.A/..*..*B/..*..*B/.*..*..*.A"  # Limerick
# FORMAT = "...../......./....."  # Haiku
# FORMAT = ".*..*.A|*..*B/.*..*.A|*..*B"
# FORMAT = ".*..*..*A/.*..*..*A/.*..*B/.*..*B/.*..*..*A"  # Limerick 2
FORMAT = ".*.*.*A/.*.*.*B/.*.*.*A/.*.*.*B"

pf = Env.get_formatter(FORMAT)
puts "\n" + pf.generate
