class Dictionary
  FULLSTOP = '.'
  FULLSTOP_WORDS = ['.', '!', '?', '."', '!"', '?""']

  SEMISTOP = ','
  SEMISTOP_WORDS = [',', '"', ';']

  attr_reader :dictionary

  def initialize(filename)
    @dictionary = {}
    puts 'Loading dictionary...' if VERBOSE
    f = File.open(filename)
    printer = ProgressPrinter.new(f)

    f.each do |line|
      printer.print_progress if VERBOSE
      next unless line.valid_encoding? && line =~ /^\w/  # Only take lines that begin with a letter (removes comments and punctuation)
      phones = line.split  # First element will be the word
      word = phones.shift.gsub(/\(\d+\)$/, '').downcase
      @dictionary[word] ||= []
      @dictionary[word] << Phonetics.new(word, phones)
    end
    puts if VERBOSE
  end

  def include?(word)
    @dictionary.include?(word.downcase)
  end

  def [](word)
    @dictionary[word.downcase]
  end
end