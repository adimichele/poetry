#!/usr/bin/env ruby
require './env'

pf = Env.get_formatter
puts "\n" + pf.generate

# Train on phonemes instead:
# 1.  Learn syllable sequences (include pauses)
# 1a. Create syllable-to-word index
# 2.  Generate sequences of syllables that matches format
# 2a. As syllables are generated, maintain a word sequences that matches and is valid.