# Suggests successive words

class Model
  attr_reader :dictionary, :corpus, :word_counts, :ngrams

  def initialize(corpora_identifiers, ngrams)
    @dictionary = Dictionary.new(RHYME_DICTIONARY_FILENAME)
    @ngrams = ngrams
    @corpus = Corpus.new(@dictionary, corpora_identifiers, @ngrams)
    @frequencies = {}
    @word_counts = {}

    @corpus.each_word_sequence do |sequence, last_item|
      add(sequence, last_item)
    end
  end

  def suggestions_for(state)
    freqs = []
    tok = state.sequence.history_token
    freqs << @frequencies[tok].normalized.select{ |word, _| @dictionary.include?(word) } if @frequencies.include?(tok)

    Suggestions.new(state, freqs, @dictionary)
  end

  # Makes sure each word in :words: can follow the given ngram
  def follows?(sequence, words)
    words = Array.wrap(words)
    return false unless @frequencies.include?(sequence.history_token)
    words.all?{ |word| @frequencies[sequence.history_token].include?(word) }
  end

  private

  def add(sequence, last_item)
    @word_counts[last_item] ||= 0
    @word_counts[last_item] += 1

    sequence.each_history_token do |tok|
      @frequencies[tok] ||= WordDist.new
      @frequencies[tok] << last_item
    end
  end
end