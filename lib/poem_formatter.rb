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
        time = Benchmark.realtime do
          result = gen(PoemState.create(@poem_format, @model))
        end
        raise NullPoemError if result.nil?
        puts "[%.1fs] (#{@count})" % time
        return result
      rescue Timeout::Error
        puts 'x'
      rescue NullPoemError
        puts "- (#{@count})"
      end
    end
  end

  private

  # Recursively generate a poem
  # TODO: Allow extra un-stressed (minor) words
  # TODO: Reset after missing a rhyme match
  # TODO: or, reset after a full level of 0 suggestions
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