#!/usr/bin/env ruby

require 'benchmark'
require 'yaml'
require 'bundler'
Bundler.require

$: << File.expand_path('../lib', __FILE__)
autoload :Corpus, 'corpus'
autoload :Dictionary, 'dictionary'
autoload :Phonetics, 'phonetics'
autoload :Model, 'model'
autoload :Suggestions, 'suggestions'
autoload :PoemFormatter, 'poem_formatter'
autoload :Syllable, 'syllable'
autoload :PoemFormat, 'poem_format'
autoload :PoemState, 'poem_state'
autoload :Rhyme, 'rhyme'
autoload :Sequence, 'sequence'
autoload :WordDist, 'word_dist'

RHYME_DICTIONARY_FILENAME = './cmudict/cmudict-0.7b'
CORPORA_PATH = './corpus'

config = YAML::load(File.read('./config.yml'))
ngrams = config['ngrams'].to_i

model = nil
elapsed = Benchmark.realtime do
  model = Model.new(RHYME_DICTIONARY_FILENAME, config['corpora'], ngrams)
end

puts '%.1fs' % elapsed

format = PoemFormat.create(config['format'])
pf = PoemFormatter.new(format, model)
puts "\n" + pf.generate