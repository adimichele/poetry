class WordDist
  def initialize(observations=nil)
    @observations = observations || {}
  end

  def push(word, weight=1.0)
    word = word.to_s
    @observations[word] ||= 0.0
    @observations[word] += weight
  end
  alias :<< :push

  def sample
    r = rand * size
    last_word = '.'
    @observations.each do |word, count|
      last_word = word
      return word if r < count && !PUNCTUATION.include?(word)
      r -= count
    end
    last_word
    # raise 'there is a bug here'
  end

  # Normalize beforehand with appropriate weighting (e.g. 10.0)
  def apply(normalized_word_dist)
    wd = clone
    normalized_word_dist.each do |k, v|
      wd.push(k, v)
    end
    wd
  end

  def normalize(weight = 1.0)
    denom = size
    obs = {}
    @observations.each do |k, v|
      obs[k] = weight * v.to_f / denom
    end
    WordDist.new(obs)
  end

  def threshold(weight)
    obs = {}
    @observations.each do |k, v|
      obs[k] = v if v >= weight
    end
    WordDist.new(obs)
  end

  def clone
    WordDist.new(@observations.clone)
  end

  def to_h
    @observations
  end

  delegate :each, to: :@observations

  def size
    @observations.values.sum.to_f
  end
end