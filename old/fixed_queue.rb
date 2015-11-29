class FixedQueue < Array
  attr_reader :history

  def initialize(size, history_size=0)
    @history = Array.new(history_size)
    super(size)
  end

  def <<(e)
    reset! if e == '.'
    shift
    super(e)
    @history.unshift(clone); @history.pop
  end

  def get_token(size=nil)
    map{ |w| w.nil? ? '*' : w }.join('-')
  end

  def reset!
    map!{ nil }
  end

  def history_full?
    @history.first.present?
  end
end