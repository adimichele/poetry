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