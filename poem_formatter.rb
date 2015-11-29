class PoemFormatter
  TIMEOUT = 5  # Seconds
  # Rules (todo)
  #

  # Formatters:
  #  . = syllable w/o stress
  #  * = syllable w/ stress
  #  A = (any letter) Rhyme marker
  #  / = line ending (pause expected)
  #  | = line ending (no pause necessary)
  def initialize(format, dictionary, model, max_ngram)
    @format = format
    @dictionary = dictionary
    @model = model
    @max_ngram = max_ngram
    @starttime = nil  # Keeps track of time spent searching
  end

  def generate
    ngram = [Dictionary::FULLSTOP]
    format = @format.clone
    rhymes = {}
    reset_timer
    gen(ngram, format, rhymes).join(' ')
  end

  private

  def reset_timer
    @starttime = Time.now
  end

  def timeout_elapsed?
    (Time.now - @starttime) >= TIMEOUT * 60
  end

  # Recursively generate a poem
  # TODO: Allow extra un-stressed (minor) words
  def gen(ngram, format, rhymes)
    raise 'oops' if ngram.length > @max_ngram

    # If we're at the end, make sure we're at a FULLSTOP and return
    if format.blank?
      if @model.follows?(ngram, Dictionary::FULLSTOP)
        return []
      else
        return nil
      end
    end

    # If we're at a pause, make sure that a FULLSTOP or SEMISTOP can follow.
    if format.start_with?('/')  # Line break
      if @model.follows?(ngram, Dictionary::SEMISTOP)
        return endline_gen([Dictionary::SEMISTOP], format, rhymes)
      elsif @model.follows?(ngram, Dictionary::FULLSTOP)
        return endline_gen([Dictionary::FULLSTOP], format, rhymes)
      else
        return nil
      end
    end

    # If we're at a non-pause line ending, just end the line.
    if format.start_with?('|')  # Line break
      return endline_gen(ngram, format, rhymes)
    end

    suggestions = @model.suggest(ngram)
    cnt = 0
    while suggestions.any?
      cnt += 1
      word = remove_word(suggestions, (ngram.size == 1))
      if @dictionary.include?(word)
        @dictionary[word].each do |phonetics|
          if phonetic_match?(phonetics, format, rhymes)
            result = next_gen(phonetics, ngram, format, rhymes)
            return [word] + result unless result.nil?
          end
        end
        # Word does not match - try again
      end

      # Stop searching if it's been too long
      if timeout_elapsed?
        reset_timer
        return nil
      end
    end

    nil  # No match
  end

  def endline_gen(ngram, format, rhymes)
    new_format = format[1, format.length]
    result = gen(ngram, new_format, rhymes)
    return ["\n"] + result unless result.nil?
    nil
  end

  def next_gen(phonetics, ngram, format, rhymes)
    new_ngram = ngram + [phonetics.word]
    new_ngram.shift if new_ngram.size >= @max_ngram

    new_format = format[phonetics.syllables.count, format.length]

    new_rhymes = rhymes.clone
    if new_format.first =~ /\w/  # Rhyme formatter
      rhyme_char = new_format.first.downcase
      new_format[0] = ''
      new_rhymes[rhyme_char] ||= phonetics
    end

    gen(new_ngram, new_format, new_rhymes)
  end

  def remove_word(wordhash, random=false)
    if random
      word = sample_word(wordhash)
    else
      # Choose most probable word
      word = wordhash.sort_by{ |_, v| -v }.first.first
    end
    wordhash.delete(word)
    word
  end

  def sample_word(wordhash)
    r = rand * wordhash.values.sum
    wordhash.each do |k, v|
      return k if r < v
      r -= v
    end
    nil
  end

  def phonetic_match?(phonetics, format, rhymes)
    subformat, rhyme = extract_subformat_and_rhyme(phonetics, format)
    matches_subformat?(phonetics, subformat) && matches_rhyme?(phonetics, rhymes[rhyme])
  end

  def extract_subformat_and_rhyme(phonetics, format)
    subformat = format[0, phonetics.syllables.count]
    rhyme = nil
    if format.length >= phonetics.syllables.count && format[phonetics.syllables.count] =~ /\w/
      rhyme = format[phonetics.syllables.count].downcase
    end
    [subformat, rhyme]
  end

  def matches_subformat?(phonetics, subformat)
    return false unless subformat =~ /^[.*]+$/  # Should not cross rhymes or line endings
    subformat.chars.each_with_index do |c, ix|
      return false if c == '*' && !phonetics.syllables[ix]  # Make sure stresses align
    end
    true
  end

  # TODO: If phonetics has fewer syllables, need to look back at previous words
  def matches_rhyme?(phonetics, rhyme_phonetics)
    return true if rhyme_phonetics.nil?
    rhyme_phonetics.rhymes_with?(phonetics)
  end
end