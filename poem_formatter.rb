class PoemFormatter
  TIMEOUT = 5  # Seconds
  # Rules (todo)
  #

  # Formatters:
  #  . = syllable w/o stress
  #  , = optional syllable w/o stress (beginning of word only)
  #  * = syllable w/ stress
  #  A = (any letter) Rhyme marker
  #  / = line ending (pause expected)
  #  | = line ending (no pause necessary)
  def initialize(format, dictionary, model, max_ngram)
    @format = format
    @dictionary = dictionary
    @model = model
    @max_ngram = max_ngram
  end

  def generate
    loop do
      begin
        Timeout::timeout(TIMEOUT) do
          return gen(@format.clone).join(' ')
        end
      rescue Timeout::Error
        puts 'Timeout elapsed. Starting over...'
      end
    end
  end

  private

  # Recursively generate a poem
  # TODO: Allow extra un-stressed (minor) words
  def gen(format, ngram=[Dictionary::FULLSTOP], rhymes={}, phones=[])
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
          if matches_phonetics?(phonetics, format, rhymes, phones)
            result = next_gen(phonetics, ngram, format, rhymes, phones)
            return [word] + result unless result.nil?
          end

          if format.start_with?(',')  # Optional non-stressed word
            new_format = format.slice(1, format.length)
            if matches_phonetics?(phonetics, new_format, rhymes, phones)
              result = next_gen(phonetics, ngram, new_format, rhymes, phones)
              return [word] + result unless result.nil?
            end
          end
        end
        # Word does not match - try again
      end
    end

    nil  # No match
  end

  def endline_gen(ngram, format, rhymes)
    new_format = format[1, format.length]
    result = gen(new_format, ngram, rhymes)  # reset phones for rhyming
    return ["\n"] + result unless result.nil?
    nil
  end

  def next_gen(phonetics, ngram, format, rhymes, phones)
    new_ngram = ngram + [phonetics.word]
    new_ngram.shift if new_ngram.size >= @max_ngram

    new_format = format[phonetics.syllables.count, format.length]

    new_rhymes = rhymes.clone
    if new_format.first =~ /\w/  # Rhyme formatter
      rhyme_char = new_format.first.downcase
      new_format[0] = ''
      new_rhymes[rhyme_char] ||= phonetics
    end

    new_phones = phones + phonetics.phones

    gen(new_format, new_ngram, new_rhymes, new_phones)
  end

  def remove_word(wordhash, random=false)
    if random
      word = wordhash.keys.sample
    else
      word = sample_word(wordhash)
      # # Choose most probable word
      # words = wordhash.sort_by{ |_, v| -v }
      # (word = words.shift.first) until word.present? && (rand < 0.5 || words.empty?)  # Randomize a bit
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

  def matches_phonetics?(phonetics, format, rhymes, phones)
    subformat, rhyme = extract_subformat_and_rhyme(phonetics, format)
    matches_subformat?(phonetics, subformat) && matches_rhyme?(phonetics, rhymes[rhyme], phones)
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
    return false unless subformat =~ /^[,.*]+$/  # Should not cross rhymes or line endings
    subformat.chars.each_with_index do |c, ix|
      return false if c == '*' && !phonetics.syllables[ix]  # Make sure stresses align
    end
    true
  end

  # TODO: If phonetics has fewer syllables, need to look back at previous words
  def matches_rhyme?(phonetics, rhyme_phonetics, phones)
    return true if rhyme_phonetics.nil?
    return false if phonetics.word == rhyme_phonetics.word
    rhyme_phonetics.rhymes_with?(phones + phonetics.phones)
  end
end