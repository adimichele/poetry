class Syllable
  attr_reader :stress, :phones

  def initialize(stress, phones=[])
    # if :phones: is empty, it means 'match any sound'
    @stress = !!stress
    @phones = phones
  end

  def clone
    p = @phones.clone
    Syllable.new(@stress, p)
  end

  def sounds_like?(format_syllable)
    # Stresses don't match only if the format_syllable is stressed and this one is not
    return false if format_syllable.stress && !@stress

    # If the format phones are empty, anything goes
    return true if format_syllable.phones.empty?

    # Otherwise, make sure each phone matches
    @phones == format_syllable.phones
  end

  def update_phones(new_phones)
    raise 'oops' unless @phones.empty?
    @phones = new_phones
  end
end