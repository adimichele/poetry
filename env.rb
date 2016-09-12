$: << File.expand_path('..', __FILE__)
require 'bundler'
Bundler.require

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


class Env

# FORMAT = ".*.*.*.*A/.*.*.*.*B/.*.*.*.*A/.*.*.*.*B"
# FORMAT = "*.*.*.*.A/*.*.*.*.A/*.*.*.*B/*.*.*.*.A/*.*.*.*.A/*.*.*.*B"
# FORMAT = ".*..*..*.A/.*..*..*.A/.*..*B/.*..*B/.*..*..*.A"  # Limerick
# FORMAT = "...../......./....."  # Haiku
# FORMAT = ".*..*.A|*..*B/.*..*.A|*..*B"
FORMAT = ".*..*..*A/.*..*..*A/.*..*B/.*..*B/.*..*..*A"  # Limerick 2
# FORMAT = ".*.*.*A/.*.*.*B/.*.*.*A/.*.*.*B"
#   FORMAT = ".*.*.*.*A/.*.*.*B/.*.*.*.*A/.*.*.*B"

# FORMAT = ".*.*.A/.*.*.A/.*.*.*B/.*.*.C/.*.*.C/.*.*.*B"
# FORMAT = ".*.*A/.*.*A/.*.*A/.*.*A/.*.*B/.*.*B/.*.*B/.*.*B"
# FORMAT = ".*.*A/.*.*A/.*.*B/.*.*B"
# FORMAT = ".*.*A/.*.*A"

  DICTIONARY = './cmudict/cmudict-0.7b'
  HISTORY_SIZE = 3  # 3 or 4
  # CORPUS = [:dpp, :poe, :twain]
  # CORPUS = ['**']
  # CORPUS = [:bible, :dpp]
  CORPUS = :shakespeare
  # CORPUS = :dickens
  # CORPUS = :twain
  # CORPUS = :trump
  # CORPUS = :dpp

  class << self
    def time
      start = Time.now
      yield
      return Time.now - start
    end

    def get_formatter
      format = PoemFormat.create(FORMAT)
      PoemFormatter.new(format, @model)
    end
  end

  elapsed = time do
    @model = Model.new(DICTIONARY, CORPUS)
  end

  puts '%.1fs' % elapsed
end
