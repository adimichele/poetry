class Dictionary
  FULLSTOP = '.'
  FULLSTOP_WORDS = ['.', '!', '?', '."', '!"', '?""']

  SEMISTOP = ','
  SEMISTOP_WORDS = [',', '"', ';']

  attr_reader :dictionary

  def initialize(filename)
    @dictionary = {}

    File.open(filename).each do |line|
      next unless line.valid_encoding? && line =~ /^\w/  # Only take lines that begin with a letter (removes comments and punctuation)
      phones = line.split  # First element will be the word
      word = phones.shift.gsub(/\(\d+\)$/, '').downcase
      @dictionary[word] ||= []
      @dictionary[word] << Phonetics.new(word, phones)
    end
  end

  def include?(word)
    @dictionary.include?(word.downcase)
  end

  def [](word)
    @dictionary[word.downcase]
  end
end