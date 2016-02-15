require 'timeout'

class NullPoemError < StandardError; end

# TODO: New formatter that searches backwards
class PoemFormatter
  TIMEOUT = 6  # Seconds

  # Formatters:
  #  . = syllable w/o stress
  #  * = syllable w/ stress
  #  A = (any letter) Rhyme marker
  #  / = line ending (pause expected)
  def initialize(format, model)
    @format = format
    @model = model
  end

  def generate
    loop do
      begin
        Timeout::timeout(TIMEOUT) do
          t = Time.now
          ngram = reset_ngram(Dictionary::FULLSTOP)
          result = gen(PoemState.new(@format.clone, ngram))
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

  def validate_format!
    if @format =~ /[^.*\w\/]/
      raise "Invalid poem format: #{@format.inspect}."
    end
  end

  def reset_ngram(word)
    ngram = Array.new(@model.ngrams - 1, nil)
    ngram[-1] = word
    ngram
  end

  # Recursively generate a poem
  # TODO: Allow extra un-stressed (minor) words
  def gen(state)

    # If we're at the end, make sure we're at a FULLSTOP and return
    return end_poem(state) if state.eof?

    # If we're at a pause, make sure that a FULLSTOP or SEMISTOP can follow.
    return line_break(state) if state.line_break?

    suggestions = @model.suggestions_for(state)
    suggestions.each do |phonetics|
      new_state = state.next_state(phonetics)
      result = gen(new_state)
      return [phonetics.word] + result unless result.nil?
    end

    nil  # No match
  end

  def end_poem(state)
    return [] if @model.follows?(state.ngram, Dictionary::FULLSTOP)
    return nil
  end

  def line_break(state)
    return endline_gen(state, Dictionary::SEMISTOP) if @model.follows?(state.ngram, Dictionary::SEMISTOP)
    return endline_gen(state, Dictionary::FULLSTOP) if @model.follows?(state.ngram, Dictionary::FULLSTOP)
    return nil
  end

  def endline_gen(state, start_word)
    ngram = reset_ngram(start_word)
    new_state = state.next_state_after_break(ngram)
    result = gen(new_state)
    return ["\n"] + result unless result.nil?
    nil
  end
end