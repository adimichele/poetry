class WordSuggestions
  # TODO: Look up suggestions based on smaller ngrams (maybe take extra word_dist arguments)
  def initialize(state, word_dist, dictionary)
    @ngram = state.ngram
    @suggestions = {}
    @dictionary = dictionary
    create_suggestions!(state, word_dist) if word_dist.present?
  end

  delegate :any?, to: :@suggestions

  def each
    while @suggestions.any?
      yield(remove_phonetics)
    end
  end

  private

  def create_suggestions!(state, word_dist)
    @suggestions = {}
    freq = word_dist.normalized
    freq.each do |word, score|
      next unless @dictionary.include?(word)
      match = nil
      @dictionary[word].each do |phonetics|
        match = phonetics if state.matches?(phonetics)
      end
      @suggestions[match] = score if match
    end
  end

  def remove_phonetics
    if @ngram.size == 1
      phonetics = @suggestions.keys.sample
    else
      phonetics = sample_suggestion
    end
    @suggestions.delete(phonetics)
    phonetics
  end

  def sample_suggestion
    r = rand * @suggestions.values.sum
    @suggestions.each do |k, v|
      return k if r < v
      r -= v
    end
    nil
  end
end