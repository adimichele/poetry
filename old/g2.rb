#!/usr/bin/env ruby
require 'active_support/all'
require 'pry'

require './model'

$filename = 'poe-narrative-695.txt'
$filename = 'huck_finn.txt'
# $filename = 'old_testament.txt'
$skip = 2

PRIOR_WEIGHT = 10.0
PUNCTUATION = '!,?'



allwords = Enumerator.new do |y|
  File.open($filename).each do |line|
    words = line.downcase.gsub(/[^a-z!'.#{PUNCTUATION}\s]/,' ').split(/\s/).reject(&:blank?)
    if words.length > 1 && $skip <= 0
      words.each do |w|
        if w =~ /[.#{PUNCTUATION}]$/
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

model = Model.new(3, 2)

allwords.each do |w|
  model.observe(w)
end

model.generate(20)
puts; puts

model.generate(20)
puts; puts

model.generate(20)
puts; puts

model.generate(20)
puts; puts


# puts 'result'
# puts s
