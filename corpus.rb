class Corpus
  #
  # Sources:
  # https://www.gutenberg.org/
  # http://textfiles.com/

  # TODO: Read from online sources
  def initialize(dictionary, corpora)
    raise 'ngrams must be > 1' unless Env::HISTORY_SIZE > 1
    corpora = [corpora] unless corpora.is_a? Array
    @dictionary = dictionary
    @filenames = []
    corpora.each do |corpus|
      files = File.join('./corpus', corpus.to_s, '*.txt')
      raise "Invalid corpus: #{corpus.inspect}" if files.empty?
      @filenames += Dir[files]
    end

    clear_history!

    # For tracking stats
    @attempts = 0
    @misses = 0
  end

  def eof?
    @filenames.empty?
  end

  def clear_history!
    @sequence = Sequence.blank
    @last_word = nil
  end

  def each_word_sequence
    each_word do |word|
      update_history(word)
      yield(@sequence, @last_word) unless @sequence.empty?
    end
    print "[#{@attempts} attempts, #{(100.0 * @misses.to_f / @attempts).round}% miss rate ]"
  end

  def each_word
    @filenames.each do |filename|
      clear_history!
      push_history!(Dictionary::FULLSTOP)
      File.open(filename).each do |line|
        extract_words(line).each do |word|
          yield(word)
        end
      end
    end
  end

  def each_syllable
    # TODO
  end

  private

  def update_history(word)
    if @last_word == Dictionary::FULLSTOP
      clear_history!
      push_history!(Dictionary::FULLSTOP)
      # Don't clear history for SEMISTOP or anything else
    end

    @attempts += 1
    
    if fullstop?(word)
      push_history!(Dictionary::FULLSTOP)
    elsif semistop?(word)
      push_history!(Dictionary::SEMISTOP)
    elsif valid_word?(word)
      push_history!(word)
    else
      # This isn't a valid word
      @misses += 1
      clear_history!
    end
  end

  def push_history!(word)
    @sequence = @sequence.plus(@last_word)
    @last_word = word
  end

  def fullstop?(word)
    Dictionary::FULLSTOP_WORDS.include?(word)
  end

  def semistop?(word)
    Dictionary::SEMISTOP_WORDS.include?(word)
  end

  def valid_word?(word)
    @dictionary.include?(word)
  end

  def extract_words(line)
    line.downcase.split(/(\s+|[\w']+|[^\w'])/).reject(&:blank?)
  end
end