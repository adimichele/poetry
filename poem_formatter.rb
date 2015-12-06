require 'timeout'

class NullPoemError < StandardError; end

# TODO: New formatter that searches backwards
class PoemFormatter
  TIMEOUT = 6  # Seconds
  # Rules (todo)
  #

  # Formatters:
  #  . = syllable w/o stress
  #  * = syllable w/ stress
  #  A = (any letter) Rhyme marker
  #  / = line ending (pause expected)
  #  | = line ending (no pause necessary)
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

  def reset_ngram(word)
    ngram = Array.new(@model.ngrams - 1, nil)
    ngram[-1] = word
    ngram
  end

  # Recursively generate a poem
  # TODO: Allow extra un-stressed (minor) words
  def gen(state)

    # If we're at the end, make sure we're at a FULLSTOP and return
    if state.eof?
      if @model.follows?(state.ngram, Dictionary::FULLSTOP)
        return []
      else
        return nil
      end
    end

    # If we're at a pause, make sure that a FULLSTOP or SEMISTOP can follow.
    if state.line_break?
      if @model.follows?(state.ngram, Dictionary::SEMISTOP)
        ngram = reset_ngram(Dictionary::SEMISTOP)
        return endline_gen(state.next_state_after_break(ngram))
      elsif @model.follows?(state.ngram, Dictionary::FULLSTOP)
        ngram = reset_ngram(Dictionary::FULLSTOP)
        return endline_gen(state.next_state_after_break(ngram))
      else
        return nil
      end
    end

    # If we're at a non-pause line ending, just end the line.
    if state.break?
      return endline_gen(state)
    end

    suggestions = @model.suggestions_for(state.ngram)
    suggestions.each do |phonetics|
      if state.matches?(phonetics)
        new_state = state.next_state(phonetics)
        result = gen(new_state)
        return [phonetics.word] + result unless result.nil?
      end
    end

    nil  # No match
  end

  def endline_gen(state)
    result = gen(state)
    return ["\n"] + result unless result.nil?
    nil
  end
end