class Phonetics
  attr_reader :phones, :syllables, :word

  MINOR_WORDS = %w{the and of a an}

  def self.is_minor?(word)
    MINOR_WORDS.include?(word.downcase)
  end

  def initialize(word, phone_symbols)
    @word = word
    @phones = []
    @syllables = []
    @rhyme_start = 0  # Highest stressed phone (vowel) - start matching rhymes here
    last_stress = -1

    phone_symbols.each do |ps|
      stress = extract_last_digit(ps)

      unless stress.nil?
        @syllables << !(Phonetics.is_minor?(word) || stress == 0)
        @rhyme_start = @phones.count if stress >= last_stress
        last_stress = stress
      end

      @phones << ps
    end
  end

  def to_s
    @phones.join('-') + ' ' + @syllables.map(&:to_s).map(&:first).join
  end

  def rhyme_phones
    @phones[@rhyme_start, @phones.length]
  end

  def rhymes_with?(other)
    self.rhyme_phones == other.rhyme_phones && self.word != other.word
  end

  private

  def extract_last_digit(phone_symbol)
    if phone_symbol =~ /\d$/
      digit = phone_symbol.last
      phone_symbol.chop!
      return digit.to_i
    else
      return nil
    end
  end
end