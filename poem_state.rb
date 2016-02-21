class PoemState
  class << self
    def create(poem_format, model)
      ngram = reset_ngram(model, Dictionary::FULLSTOP)
      PoemState.new(model, poem_format, ngram)
    end

    def reset_ngram(model, word)
      ngram = Array.new(model.ngrams - 1, nil)
      ngram[-1] = word
      ngram
    end
  end

  attr_reader :ngram, :poem_format

  def initialize(model, poem_format, ngram)
    @poem_format = poem_format
    @ngram = ngram
    @model = model
  end

  def eof?
    @poem_format.eof?
  end

  def matches?(phonetics)
    return false unless @poem_format.matches?(phonetics)
    return true unless ends_line?(phonetics)
    @model.follows?(next_ngram(phonetics.word), [Dictionary::FULLSTOP, Dictionary::SEMISTOP])
  end

  def ends_line?(phonetics)
    @poem_format.ends_line?(phonetics)
  end

  def next_state(phonetics)
    new_ngram = next_ngram(phonetics.word)
    new_format = @poem_format.trim_format(phonetics)
    PoemState.new(@model, new_format, new_ngram)
  end

  private

  def next_ngram(word)
    new_ngram = @ngram + [word]
    new_ngram.shift
    new_ngram
  end
end