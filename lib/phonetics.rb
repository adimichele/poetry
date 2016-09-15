class Phonetics
  attr_reader :syllables, :word

  MINOR_WORDS = %w{the and of a an}

  def self.is_minor?(word)
    MINOR_WORDS.include?(word.downcase)
  end

  def initialize(word, phone_symbols)
    @word = word
    @syllables = []
    @rhyme_start = 0  # Highest stressed phone (vowel) - start matching rhymes here

    last_syllable = nil
    phone_symbols.each do |ps|
      stress = extract_last_digit(ps)
      last_syllable.phones << ps unless last_syllable.nil? || stress

      unless stress.nil?
        stress = !(Phonetics.is_minor?(word) || stress == 0)
        last_syllable = Syllable.new(stress, [ps])
        @syllables << last_syllable
        @rhyme_start = @syllables.count if stress == 1
      end
    end
  end

  def rhyme_syllables
    @syllables[@rhyme_start, @syllables.length]
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