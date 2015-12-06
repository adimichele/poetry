class PoemState
  attr_reader :ngram, :rhymes, :phones

  # TODO: Add format
  def initialize(format, ngram, rhymes={}, phones=[])
    @format = format || ''
    @ngram, @rhymes, @phones = ngram, rhymes, phones
  end

  def eof?
    @format.blank?
  end

  def line_break?
    @format.start_with?('/')
  end

  def break?
    @format.start_with?('|') || line_break?
  end

  def matches?(phonetics)
    subformat, rhyme = extract_subformat_and_rhyme(phonetics)
    matches_subformat?(phonetics, subformat) && matches_rhyme?(phonetics, @rhymes[rhyme], @phones)
  end

  def next_state_after_break(ngram)
    new_format = @format[1, @format.length]
    # reset phones for rhyming
    PoemState.new(new_format, ngram, @rhymes)
  end

  def next_state(phonetics)
    new_ngram = @ngram + [phonetics.word]
    new_ngram.shift

    new_format = @format[phonetics.syllables.count, @format.length] || ''

    new_rhymes = @rhymes.clone
    if new_format.first =~ /\w/  # Rhyme formatter
      rhyme_char = new_format.first.downcase
      new_format[0] = ''
      new_rhymes[rhyme_char] ||= Rhyme.new(phonetics)
      new_rhymes[rhyme_char].words << phonetics.word
    end

    new_phones = @phones + phonetics.phones

    PoemState.new(new_format, new_ngram, new_rhymes, new_phones)
  end

  private

  def extract_subformat_and_rhyme(phonetics)
    subformat = @format[0, phonetics.syllables.count]
    rhyme = nil
    if @format.length >= phonetics.syllables.count && @format[phonetics.syllables.count] =~ /\w/
      rhyme = @format[phonetics.syllables.count].downcase
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
  def matches_rhyme?(phonetics, rhyme, phones)
    return true if rhyme.nil?
    return false if rhyme.words.include?(phonetics.word)
    rhyme.rhymes_with?(phones + phonetics.phones)
  end
end

class Rhyme
  attr_reader :phones, :words

  def initialize(phonetics)
    @phones = phonetics.rhyme_phones
    @words = Set.new
  end

  def rhymes_with?(other_phones)
    rhyme_size = @phones.count
    other_phones = other_phones.slice(-rhyme_size, rhyme_size)
    @phones == other_phones
  end
end