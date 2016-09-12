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

  def same_endings?(phonetics)
    rhyme_size = [@phones.count, phonetics.rhyme_phones.count].min
    rhyme1 = @phones.slice(-rhyme_size, rhyme_size)
    rhyme2 = phonetics.rhyme_phones.slice(-rhyme_size, rhyme_size)
    rhyme1 == rhyme2
  end
end