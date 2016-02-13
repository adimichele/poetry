class PoemNode
  def self.create_tree(format, model)
    loop do
      begin
        Timeout::timeout(TIMEOUT) do
          t = Time.now
          ngram = reset_ngram(Dictionary::FULLSTOP)
          state = PoemState.new(format.clone, ngram)
          pn = PoemNode.new(nil, state, nil, model)

          # TODO

          # result = gen(PoemState.new(@format.clone, ngram))
          # raise NullPoemError if result.nil?
          # puts '[%.1fs]' % (Time.now - t)
          # return result.join(' ')
        end
      rescue Timeout::Error
        print '.'
      rescue NullPoemError
        print '-'
      end
    end
  end

  attr_reader :line_break

  def initialize(last_node, state, phonetics, model)
    raise 'Not a match' unless state.matches?(phonetics)
    @last = last_node
    @state = state
    @phonetics = phonetics
    @next_state = state.next_state(phonetics)
    @model = model
    @line_break = false
    @children = Set.new

    # TODO: divide by word frequency?
    @score = @phonetics.syllables.count.to_f

    if @next_state.eof?
      if @model.follows?(@next_state.ngram, Dictionary::FULLSTOP)
        @score += 3
      end
    end

    if @next_state.line_break?
      @line_break = true
      if @model.follows?(@next_state.ngram, Dictionary::SEMISTOP)
        # TODO: Don't reset after semistop
        @new_state = @next_state.next_state_after_break(self.reset_ngram(Dictionary::SEMISTOP))
        @score += 1
      elsif @model.follows?(@next_state.ngram, Dictionary::FULLSTOP)
        @new_state = @next_state.next_state_after_break(self.reset_ngram(Dictionary::FULLSTOP))
        @score += 2
      else
        @new_state = @next_state.next_state_after_break(self.reset_ngram(Dictionary::FULLSTOP))
      end
    end

    @suggestions = @model.suggestions_for(@new_state)
  end

  def valid?
    @children.any? || eof?
  end

  #
  def add_children(max=3)
    @suggestions.each do |phonetics|
      return if @children.size >= max
      child = PoemNode.new(self, @next_state, phonetics, @model)
      child.add_children(max)
      @children << child if child.valid?
    end
  end

  def score
    @score * @score + @children.map(&:score).max
  end

  def best_poem
    return '' if eof?
    best_child = @children.first
    best_score = @children.first.score
    @children.each do |child|
      score = child.score
      best_child, best_score = child, score if score > best_score
    end
    return @phonetics.word + (@line_break ? "\n" : ' ') + best_child.best_poem
  end

  def line_break?
    @line_break
  end

  def eof?
    @next_state.eof?
  end

  private

  def self.reset_ngram(word)
    ngram = Array.new(@model.ngrams - 1, nil)
    ngram[-1] = word
    ngram
  end

end