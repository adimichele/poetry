$: << File.expand_path('..', __FILE__)
require 'bundler'
Bundler.require

autoload :Corpus, 'corpus'
autoload :Dictionary, 'dictionary'
autoload :Phonetics, 'phonetics'
autoload :Model, 'model'
autoload :PoemFormatter, 'poem_formatter'
