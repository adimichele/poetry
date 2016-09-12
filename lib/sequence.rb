class Sequence
  # :immutable:

  def self.blank(ngrams)
    self.new(Array.new(ngrams - 1), ngrams)
  end

  def initialize(history, ngrams)
    raise 'Wrong history size' unless history.size == ngrams - 1
    @ngrams = ngrams
    @history = history
  end

  # Iterates through histories, starting with longest
  # TODO: Make this configurable
  def each_history_token
    h = @history.clone
    while h.size > 0
      yield(token_for(h))
      h.shift
    end
  end

  def history_token
    @history_token ||= token_for(@history)
  end

  # Similar to #push except it returns a new Sequence
  def plus(word)
    new_history = @history + [word]
    new_history.shift
    Sequence.new(new_history, @ngrams)
  end

  def empty?
    @history.all?(&:nil?)
  end

  private

  def token_for(sequence)
    sequence.reject{ |w| w.nil? }.map(&:to_s).join('|')
  end
end