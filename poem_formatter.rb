require 'timeout'

class NullPoemError < StandardError; end

PoemResult = Struct.new(:words, :score)

class PoemFormatter
  TIMEOUT = 10  # Seconds

  def initialize(poem_format, model)
    @poem_format = poem_format
    @model = model
  end

  def generate
    loop do
      begin
        Timeout::timeout(TIMEOUT) do
          t = Time.now
          result = gen(PoemState.create(@poem_format, @model))
          raise NullPoemError if result.nil?
          puts '[%.1fs]' % (Time.now - t)
          return result.join(' ')
        end
      rescue Timeout::Error
        print '.'
      rescue NullPoemError
        print '-'
      end
    end
  end

  private

  # Recursively generate a poem
  # TODO: Allow extra un-stressed (minor) words
  def gen(state)

    # If we're at the end, make sure we're at a FULLSTOP and return
    return end_poem(state) if state.eof?

    suggestions = @model.suggestions_for(state)
    suggestions.each do |phonetics|
      new_state = state.next_state(phonetics)
      result = gen(new_state)
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