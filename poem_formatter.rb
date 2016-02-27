require 'timeout'

class NullPoemError < StandardError; end

PoemResult = Struct.new(:words, :score)

class PoemFormatter
  TIMEOUT = 10  # Seconds

  def initialize(poem_format, model)
    @poem_format = poem_format
    @model = model
    @poem_so_far = []
  end

  def generate
    loop do

      begin
        @count = 0
        t = Time.now
        result = gen(PoemState.create(@poem_format, @model))
        raise NullPoemError if result.nil?
        puts "[%.1fs] (#{@count})" % (Time.now - t)
        return result.join(' ')
      rescue Timeout::Error
        puts "x (#{@count})"
        puts @poem_so_far.join(' ')
        @poem_so_far = []
      rescue NullPoemError
        puts "- (#{@count})"
      end
    end
  end

  private

  # Recursively generate a poem
  # TODO: Allow extra un-stressed (minor) words
  def gen(state)
    @count += 1
    raise Timeout::Error if @count >= 100000
    # If we're at the end, make sure we're at a FULLSTOP and return
    return end_poem(state) if state.eof?

    suggestions = @model.suggestions_for(state)
    suggestions.each do |phonetics|
      new_state = state.next_state(phonetics)

      ## Logging
      if state.ends_line?(phonetics)
        @poem_so_far.push(phonetics.word + "\n")
      else
        @poem_so_far.push(phonetics.word)
      end
      ## Logging

      result = gen(new_state)

      ## Logging
      @poem_so_far.pop
      ## Logging

      next if result.nil?

      if state.ends_line?(phonetics)
        return [phonetics.word, "\n"] + result
      else
        return [phonetics.word] + result
      end
    end

    nil  # No match
  end

  def end_poem(state)
    return [] if @model.follows?(state.ngram, Dictionary::FULLSTOP)
    return nil
  end
end