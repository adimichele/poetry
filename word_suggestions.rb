class WordSuggestions
  # :word_dists: is an ordered array of word frequencies - first item takes most precedence
  def initialize(state, word_dists, dictionary)
    word_dists = Array.wrap(word_dists).compact
    @suggestions = []
    @seen = Set.new
    @dictionary = dictionary
    word_dists.each do |word_dist|
      sug = create_suggestions!(state, word_dist)
      @suggestions << sug if sug.any?
    end
  end

  delegate :any?, to: :@suggestions

  def each
    while @suggestions.any?
      yield(remove_phonetics)
    end
  end

  private

  def create_suggestions!(state, word_dist)
    sug = {}
    freq = word_dist.normalized
    freq.each do |word, score|
      next unless @dictionary.include?(word)
      next if @seen.include?(word)
      @seen.add(word)
      @dictionary[word].each do |phonetics|
        # next unless state.matches?(phonetics)
        # NB: This takes all valid pronunciations
        sug[phonetics] = score + phonetics.syllables.count if state.matches?(phonetics)
      end
    end
    sug
  end

  def remove_phonetics
    phonetics = sample_suggestion
    current_suggestion.delete(phonetics)
    @suggestions.shift if current_suggestion.empty?
    phonetics
  end

  def sample_suggestion
    r = rand * current_suggestion.values.sum
    current_suggestion.each do |k, v|
      return k if r < v
      r -= v
    end
    nil
  end

  def current_suggestion
    @suggestions.first
  end
end