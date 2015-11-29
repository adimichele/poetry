require './fixed_queue'
require './word_dist'

class WordLookup
  def initialize(look_back)
    @look_back = look_back
    @lookup = Array.new(look_back){ {} }
  end

  def add(word, ngram)
    @lookup.each_with_index do |freq, lb|
      tok = token_for(ngram, lb+1)
      freq[tok] ||= WordDist.new
      freq[tok] << word
    end
  end

  # Fall back on smaller ngrams if no match
  def lookup(ngram)
    @look_back.times.to_a.reverse.each do |size|
      tok = token_for(ngram, size+1)
      return @lookup[size][tok] if @lookup[size].include?(tok)
      binding.pry if size == 0  # Couldn't find a single word
    end
  end

  private

  def token_for(ngram, size)
    ngram.reverse[0, size].reverse.map{ |w| w.nil? ? '*' : w }.join('-')
  end
end

class Model
  def initialize(look_back, look_ahead)
    @look_back, @look_ahead = look_back, look_ahead
    @lb_queue = FixedQueue.new(look_back, look_ahead)
    @lb_queue << '.'
    @frequencies = Array.new(look_ahead){ WordLookup.new(@look_back) }
    @priors = WordDist.new
  end

  def observe(word)
    @priors << word
    @lb_queue.history.each_with_index do |lb, ix|
      next if lb.nil?
      @frequencies[ix].add(word, lb)
    end
    @lb_queue << word
  end

  def generate(min_length)
    result = []
    la_freq = Array.new(@look_ahead){ @priors.normalize(PRIOR_WEIGHT) }
    lbq = FixedQueue.new(@look_back)
    lbq << '.'

    loop do
      @frequencies.each_with_index do |wf, ix|
        freq = wf.lookup(lbq)
        la_freq[ix] = freq.apply(la_freq[ix].normalize(PRIOR_WEIGHT)) unless freq.nil?
      end

      # This first slot holds the next word
      thresh_freq = la_freq.first.threshold(1.0)
      thresh_freq = la_freq.first if thresh_freq.size < 1
      word = thresh_freq.sample
      lbq << word
      result << word

      # Advance each slot, add priors to new slot
      la_freq.shift
      la_freq.push(@priors.normalize(PRIOR_WEIGHT))

      return if word == '.' || result.length >= 100

      print word + ' '
    end
  end

  # def generate(min_length)
  #   lbq = FixedQueue.new(@look_back)
  #   lbq << '.'
  #   result = []
  #   la_freq = Array.new(@look_ahead){ {} }  # Look-ahead frequencies
  #
  #   loop do
  #     la_freq.shift
  #     la_freq << {}
  #     word = choose_word(lbq, la_freq)
  #     result << word
  #     lbq << word
  #     return result.join(' ') if result.length >= min_length && word == '.' || result.length >= 1000
  #   end
  # end
  #
  # private
  #
  # def merge_freq!(h1, h2)
  #   (h2 || {}).each do |k,v|
  #     h1[k] ||= 0
  #     h1[k] += v
  #   end
  #   h1
  # end
  #
  # def choose_word(lbq, la_freq)
  #   tok = lbq.get_token
  #   @frequencies.each_with_index do |freq, ix|
  #     merge_freq!(la_freq[ix], freq[tok])
  #   end
  #
  #   freq = la_freq[0]
  #   raise 'oops' if freq.nil?
  #   den = freq.values.sum.to_f
  #   cum = 0.0
  #   r = rand
  #   freq.each do |word, num|
  #     cum += num.to_f / den
  #     return word if r < cum
  #   end
  # end

end