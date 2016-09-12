class PoemState
  class << self
    def create(poem_format, model)
      sequence = Sequence.blank(model.ngrams).plus(Dictionary::FULLSTOP)
      PoemState.new(model, poem_format, sequence)
    end
  end

  attr_reader :sequence, :poem_format, :poem

  def initialize(model, poem_format, sequence, poem='')
    @poem_format = poem_format
    @sequence = sequence
    @model = model
    @poem = poem
  end

  def eof?
    @poem_format.eof?
  end

  def matches?(phonetics)
    return false unless @poem_format.matches?(phonetics)
    return true unless ends_line?(phonetics)
    @model.follows?(@sequence.plus(phonetics.word), [Dictionary::FULLSTOP, Dictionary::SEMISTOP])
  end

  def ends_line?(phonetics)
    @poem_format.ends_line?(phonetics)
  end

  def next_state(phonetics)
    next_sequence = @sequence.plus(phonetics.word)
    new_format = @poem_format.trim_format(phonetics)

    new_poem = poem + ' ' + phonetics.word
    new_poem += "\n" if ends_line?(phonetics)

    PoemState.new(@model, new_format, next_sequence, new_poem)
  end
end