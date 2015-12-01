$: << File.expand_path('..', __FILE__)
require 'bundler'
Bundler.require

autoload :Corpus, 'corpus'
autoload :Dictionary, 'dictionary'
autoload :Phonetics, 'phonetics'
autoload :Model, 'model'
autoload :PoemFormatter, 'poem_formatter'

DICTIONARY = './cmudict/cmudict-0.7b'
NGRAMS = 3
CORPUS = :bible

class Env
  attr_reader :dictionary, :corpus, :model

  class << self
    def time
      start = Time.now
      yield
      return Time.now - start
    end

    def get_formatter(format)
      PoemFormatter.new(FORMAT, @dictionary, @model, NGRAMS)
    end
  end

  print 'Loading dictionary...'
  elapsed = time do
    @dictionary = Dictionary.new(DICTIONARY)
  end
  puts '%.1fs' % elapsed

  @corpus = Corpus.new(CORPUS, NGRAMS) do |word|
    @dictionary.include?(word)
  end

  @model = Model.new

  print 'Loading corpus...'
  elapsed = time do
    @corpus.each do |ngram|
      @model << ngram
    end
  end
  puts '%.1fs' % elapsed
end