class WordSuggestions
  def initialize(state, word_dist, dictionary)
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
      @dictionary[word].each do |phonetics|
        # next unless state.matches?(phonetics)
        # NB: This takes all valid pronunciations
        @suggestions[phonetics] = score + phonetics.syllables.count if state.matches?(phonetics)
      end
    end
  end

  def remove_phonetics
    phonetics = sample_suggestion
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