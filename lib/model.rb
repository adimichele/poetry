# Suggests successive words

class Model
  attr_reader :dictionary, :corpus, :word_counts

  def initialize(dictionary_filename, corpora_identifiers)
    puts "\tLoading dictionary..."
    @dictionary = Dictionary.new(dictionary_filename)
    puts "\tLoading corpora..."
    @corpus = Corpus.new(@dictionary, corpora_identifiers)
    @frequencies = {}
    @word_counts = {}

    # TODO: Go through each syllable instead
    puts "\tTraining model..."
    @corpus.each_word_sequence do |sequence, last_item|
      add(sequence, last_item)
    end
  end

  def suggestions_for(state)
    freqs = []

    # TODO: Configure # histories to search - seems to work well when only searching the longest history
    # state.sequence.each_history_token do |tok|
    #   # TODO: Look into the miss rate here
    #   freqs << @frequencies[tok].normalized.select{ |word, _| @dictionary.include?(word) } if @frequencies.include?(tok)
    # end
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