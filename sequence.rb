class Sequence
  # :immutable:

  def self.blank
    self.new(Array.new(Env::HISTORY_SIZE - 1))
  end

  def initialize(history)
    raise 'Wrong history size' unless history.size == Env::HISTORY_SIZE - 1
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
    Sequence.new(new_history)
  end

  def empty?
    @history.all?(&:nil?)
  end

  private

  def token_for(sequence)
    sequence.reject{ |w| w.nil? }.map(&:to_s).join('|')
  end
end