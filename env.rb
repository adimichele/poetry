$: << File.expand_path('..', __FILE__)
require 'bundler'
Bundler.require

autoload :Corpus, 'corpus'
autoload :Dictionary, 'dictionary'
autoload :Phonetics, 'phonetics'
autoload :Model, 'model'
autoload :WordSuggestions, 'word_suggestions'
autoload :PoemFormatter, 'poem_formatter'
autoload :Syllable, 'syllable'
autoload :PoemFormat, 'poem_format'
autoload :PoemState, 'poem_state'
autoload :Rhyme, 'rhyme'


class Env
  DICTIONARY = './cmudict/cmudict-0.7b'
  NGRAMS = 3 # 4 is great
  # CORPUS = [:dpp, :poe, :twain]
  # CORPUS = ['**']
  CORPUS = :shakespeare
  # CORPUS = :dickens
  # CORPUS = :twain

  class << self
    def time
      start = Time.now
      yield
      return Time.now - start
    end

    def get_formatter(fmt)
      format = PoemFormat.create(fmt)
      PoemFormatter.new(format, @model)
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

  print 'Training model with corpus...'
  elapsed = time do
    @model = Model.new(@dictionary, @corpus)
  end

  puts '%.1fs' % elapsed
end
