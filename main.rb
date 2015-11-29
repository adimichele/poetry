#!/usr/bin/env ruby
require './env'
require 'timeout'

NGRAMS = 3

@dict = Dictionary.new

@corpus = Corpus.new(:twain, NGRAMS) do |word|
  @dict.include?(word)
end

@model = Model.new

@corpus.each do |ngram|
  @model << ngram
end

def sample(wordhash)
  r = rand * wordhash.values.sum
  wordhash.each do |k, v|
    return k if r < v
    r -= v
  end
end

# ap @model.suggest(['once', 'upon']).sort_by{ |k,v| v }

FORMAT = ".*.*.*.*A/.*.*.*.*B/.*.*.*.*A/.*.*.*.*B"
# FORMAT = ".*..*..*.A/.*..*..*.A/.*..*B/.*..*B/.*..*..*.A"  # Limerick
# FORMAT = "...../......./....."

pf = PoemFormatter.new(FORMAT, @dict, @model, NGRAMS)
puts pf.generate

# DFS to find a poem that matches the format

# def generate(ngram, format, rhymes={})
#   return [] if format.blank?
#
#   if format.start_with?('/')
#     new_format = format[1, format.length]
#     result = generate(ngram, new_format, rhymes)
#     return ["\n"] + result unless result.nil?
#     return nil
#   end
#
#   suggestions = @model.suggest(ngram)
#
#   # Grab suggestions until one is found that matches the format
#   while suggestions.any?
#     word = sample(suggestions)
#     phonetics = @dict[word]
#
#     if (matched_phonetics = matches_format?(phonetics, format, rhymes))
#       result = generate(*updated_args(word, matched_phonetics, ngram, format, rhymes))
#       return [word] + result unless result.nil?
#     end
#
#     suggestions.delete(word)
#   end
#
#   nil  # No match
# end
#
# #
# def matches_format?(phonetics, format, rhymes)
#   phonetics.each do |p|
#     subformat = format[0, p.syllables.count]
#     rhyme = format[p.syllables.count].try(:downcase)
#
#     if matches_subformat?(p.syllables, subformat)
#       return p unless rhyme =~ /\w/ && rhymes.include?(rhyme)
#       return p if matches_rhyme?(p, rhymes[rhyme])
#     end
#   end
#
#   false
# end
#
# def matches_subformat?(syllables, subformat)
#   return false unless subformat =~ /^[.*]+$/  # Should not cross rhymes or line endings
#   subformat.chars.each_with_index do |c, ix|
#     return false if c == '*' && !syllables[ix]  # Make sure stresses align
#   end
#   true
# end
#
# def matches_rhyme?(phonetics, rhyme_phonetics)
#   # TODO: make sure no words match wne there are more than 1
#   return phonetics.rhyme_phones == rhyme_phonetics.rhyme_phones && phonetics.phones != rhyme_phonetics.phones
# end
#
# # returns ngram, format, rhymes
# def updated_args(word, phonetics, ngram, format, rhymes)
#   new_ngram = ngram + [word]
#   new_ngram.shift if new_ngram.size > NGRAMS
#
#   new_format = format[phonetics.syllables.count, format.length]
#
#   new_rhymes = rhymes.clone
#   if new_format.first =~ /\w/  # Rhyme formatter
#     rhyme_char = new_format.first.downcase
#     new_format[0] = ''
#     new_rhymes[rhyme_char] ||= phonetics
#   end
#
#   [new_ngram, new_format, new_rhymes]
# end
#
# 5.times do
#   # TODO: Validate that the next word generated could be FULLSTOP
#   # TODO: Don't let 'the' be a stressed word
#   # TODO: (system for applying rules like the above)
#   puts generate(['.'], FORMAT).join(' ')
#   puts
# end