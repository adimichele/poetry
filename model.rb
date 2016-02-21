# Suggests successive words

class Model
  attr_reader :dictionary, :corpus, :word_counts

  def initialize(dictionary, corpus)
    @dictionary = dictionary
    @corpus = corpus
    @frequencies = {}
    @word_counts = {}

    @corpus.each do |ngram|
      add(ngram)
    end
  end

  def ngrams
    @corpus.ngrams
  end

  # NB: Search through smaller ngrams as well?
  def suggestions_for(state)
    tok = token_for(state.ngram)
    WordSuggestions.new(state, @frequencies[tok], @dictionary)
  end

  # Makes sure each word in :words: can follow the given ngram
  def follows?(ngram, words)
    words = [words] unless words.is_a? Array
    tok = token_for(ngram)
    return false unless @frequencies.include?(tok)
    words.all?{ |word| @frequencies[tok].include?(word) }
  end

  private

  def add(ngram)
    word = ngram.pop

    @word_counts[word] ||= 0
    @word_counts[word] += 1

    while ngram.size > 0
      tok_ngram = make_ngram_full_size(ngram)
      tok = token_for(tok_ngram)
      @frequencies[tok] ||= WordDist.new
      @frequencies[tok] << word
      ngram.shift  # store all possible 'grams
    end
  end

  def make_ngram_full_size(ngram)
    Array.new(ngrams - ngram.size - 1) + ngram
  end

  def token_for(ngram)
    raise "Ngram (#{ngram.size}) should always be the same size (#{ngrams - 1})." unless ngram.size == ngrams - 1
    ngram.reject{ |w| w.nil? }.join('|')
  end
end

class WordDist
  attr_reader :observations

  def initialize
    @observations = {}
  end

  def <<(word)
    word = word.to_s.downcase
    @observations[word] ||= 0.0
    @observations[word] += 1.0
  end

  def include?(word)
    @observations.include?(word.to_s.downcase)
  end

  def normalized
    total = @observations.values.sum
    obs = {}
    @observations.each do |word, count|
      obs[word] = count / total
    end
    obs
  end
end