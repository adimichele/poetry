#!/usr/bin/env ruby

require 'yaml'
require 'bundler'
Bundler.require

RHYME_DICTIONARY_FILENAME = File.expand_path('../cmudict/cmudict-0.7b', __FILE__)
CORPORA_PATH = File.expand_path('../corpus', __FILE__)
CONFIG_FILENAME = File.expand_path('../config.yml', __FILE__)
VERBOSE = true

Dir[File.expand_path('../lib/**/*.rb', __FILE__)].each{ |file| require file }

config = YAML::load(File.read(CONFIG_FILENAME))
model = Model.new(config['corpora'], config['ngrams'].to_i)
format = PoemFormat.parse(config['format'])
pf = PoemFormatter.new(format, model)
poem = pf.generate
puts if VERBOSE
puts poem