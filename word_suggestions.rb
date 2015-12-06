class WordSuggestions
  # TODO: Look up suggestions based on smaller ngrams (maybe take extra word_dist arguments)
  def initialize(ngram, word_dist, dictionary)
    @ngram = ngram
    @suggestions = {}
    @dictionary = dictionary
    create_suggestions!(word_dist) if word_dist.present?
  end

  delegate :any?, to: :@suggestions

  def each
    while @suggestions.any?
      word = remove_word
      @dictionary[word].each do |phonetics|
        yield(phonetics)
      end
    end
  end

  private

  def create_suggestions!(word_dist)
    freq = word_dist.normalized
    freq.each do |word, score|
      if @dictionary.include?(word)
        @suggestions[word] = score
      end
    end
  end

  def remove_word
    if @ngram.size == 1
      word = @suggestions.keys.sample
    else
      word = sample_word
    end
    @suggestions.delete(word)
    word
  end

  def sample_word
    r = rand * @suggestions.values.sum
    @suggestions.each do |k, v|
      return k if r < v
      r -= v
    end
    nil
  end
end