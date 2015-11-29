#!/usr/bin/env ruby
require 'active_support/all'
require 'pry'
$filename = 'poe-narrative-695.txt'
$skip = 2
$look_back = 2
$look_ahead = 2

allwords = Enumerator.new do |y|
  File.open($filename).each do |line|
    words = line.downcase.gsub(/[^a-z!',.?\s]/,'').split(/\s/).reject(&:blank?)
    if words.length > 1 && $skip <= 0
      words.each do |w|
        if w =~ /[!,.?]$/
          wl = w.last
          y << w.chop
          y << wl
        else
          y << w
        end
      end
    elsif words.length > 1 && $skip > 0
      $skip -= 1
    end
  end
end

last_word = '.'
vocab = Set.new([last_word])
counts = {last_word => 0}
bigrams = {last_word => {}}

allwords.each do |w|
  unless vocab.include?(w)
    counts[w] = 0
    bigrams[w] = {}
    vocab << w
  end
  counts[w] += 1
  bigrams[last_word][w] ||= 0
  bigrams[last_word][w] += 1
  last_word = w
end

bigram_model = {}
bigrams.each do |w, bg|
  den = bg.values.sum.to_f
  #bigram_model[w] = bg.to_a.sort_by{ |a| -a[1] }
  model = bg.map{ |k, v| OpenStruct.new(word: k, weight: v.to_f / den) }
  last_weight = 0.0
  model.map do |os|
    os.weight += last_weight
    last_weight = os.weight
  end
  bigram_model[w] = model
end

#binding.pry

# Generate a poem
len = 20
poem = []
last_word = '.'

loop do
  word = nil
  r = rand
  bigram_model[last_word].each do |os| 
    word = os.word and break if r < os.weight
  end
  raise('oops') if word.nil?
  poem << word
  last_word = word
  break if poem.length > len && last_word == '.'
end

puts poem.join(' ')
