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
        result = nil
        result = gen(PoemState.create(@poem_format, @model))
        raise NullPoemError if result.nil?
        return result
      rescue Timeout::Error
        puts 'Search timed out. Restarting...' if VERBOSE
      # rescue NullPoemError
      end
    end
  end

  private

  # Recursively generate a poem
  # TODO: Allow extra un-stressed (minor) words
  def gen(state)
    @count += 1
    raise Timeout::Error if @count >= 20000
    # If we're at the end, make sure we're at a FULLSTOP and return
    return end_poem(state) if state.eof?

    suggestions = @model.suggestions_for(state)
    suggestions.each do |phonetics|
      new_state = state.next_state(phonetics)
      result = gen(new_state)
      next if result.nil?
      return result
    end

    nil  # No match
  end

  def end_poem(state)
    return state.poem if @model.follows?(state.sequence, Dictionary::FULLSTOP)
    return nil
  end
end