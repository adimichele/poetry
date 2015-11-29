# Suggests successive words

class Model
  def initialize
    @frequencies = {}
  end

  def <<(ngram)
    word = ngram.pop

    while ngram.size > 0
      tok = token_for(ngram)
      @frequencies[tok] ||= WordDist.new
      @frequencies[tok] << word
      ngram.shift  # store all possible 'grams
    end
  end

  # TODO: Limit by ngram size?
  def suggest(ngram)
    suggestions = {}
    ngram = ngram.clone

    # while ngram.size > 0
      tok = token_for(ngram)
      gramscore = ngram.size.to_f
      if @frequencies.include?(tok)
        freq = @frequencies[tok].normalized
        freq.each do |word, score|
          score *= gramscore
          suggestions[word] ||= 0
          suggestions[word] = score if score > suggestions[word]
        end
      end
      ngram.shift
    # end

    suggestions
  end

  def follows?(ngram, word)
    tok = token_for(ngram)
    return @frequencies.include?(tok) && @frequencies[tok].include?(word)
  end

  private

  def token_for(ngram)
    ngram.join('|')
  end
end

class WordDist
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