class Suggestions
  # :freq_dists: is an ordered array of word frequencies - first item takes most precedence
  def initialize(state, freq_dists, dictionary)
    freq_dists = Array.wrap(freq_dists).compact
    @suggestions = []
    @seen = Set.new
    @dictionary = dictionary
    freq_dists.each do |freq_dist|
      sug = create_suggestions!(state, freq_dist)
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

  def create_suggestions!(state, freq_dist)
    sug = {}
    freq_dist.each do |word, score|
      next if @seen.include?(word)
      @seen.add(word)
      @dictionary[word].each do |phonetics|
        # next unless state.matches?(phonetics)
        # NB: This takes all matching pronunciations
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