class Corpus
  #
  # Sources:
  # https://www.gutenberg.org/
  # http://textfiles.com/

  attr_reader :ngrams

  # TODO: Read from online sources
  def initialize(corpora, ngrams=2, &word_validator_block)
    raise 'ngrams must be > 1' unless ngrams > 1
    corpora = [corpora] unless corpora.is_a? Array
    @ngrams = ngrams
    @word_validator_block = word_validator_block
    @filenames = []
    corpora.each do |corpus|
      files = File.join('./corpus', corpus.to_s, '*.txt')
      raise "Invalid corpus: #{corpus.inspect}" if files.empty?
      @filenames += Dir[files]
    end
    @history = []

    # For tracking stats
    @attempts = 0
    @misses = 0
  end

  def eof?
    @filenames.empty?
  end

  def clear_history!
    @history = Array.new(@ngrams)
  end

  def each
    @filenames.each do |filename|
      clear_history!
      push_history!(Dictionary::FULLSTOP)
      File.open(filename).each do |line|
        extract_words(line).each do |word|
          update_history(word)
          yield @history.clone if enough_history?
        end
      end
    end
    print "[#{@attempts} attempts, #{(100.0 * @misses.to_f / @attempts).round}% miss rate ]"
  end

  private

  def update_history(word)
    if last_word == Dictionary::FULLSTOP
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
    @history.shift while @history.size >= @ngrams
    @history << word
  end
  
  def last_word
    @history.last
  end

  def fullstop?(word)
    Dictionary::FULLSTOP_WORDS.include?(word)
  end

  def semistop?(word)
    Dictionary::SEMISTOP_WORDS.include?(word)
  end

  def valid_word?(word)
    return true unless @word_validator_block.present?
    !!@word_validator_block.call(word)
  end

  def extract_words(line)
    line.downcase.split(/(\s+|[\w']+|[^\w'])/).reject(&:blank?)
  end

  def enough_history?
    @history.reject(&:nil?).count > 1
  end
end