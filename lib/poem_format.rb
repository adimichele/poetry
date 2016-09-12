class PoemFormat
  class Line < Struct.new(:rhyme, :syllables)
    def clone
      s = self.syllables.map(&:clone)
      Line.new(self.rhyme, s)
    end
  end

  def self.create(fmt)
    lines = []
    line = Line.new(nil, [])
    lines << line
    fmt.chars.each do |c|
      if c == '.'
        line.syllables << Syllable.new(false)
      elsif c == '*'
        line.syllables << Syllable.new(true)
      elsif c == '/'
        line = Line.new(nil, [])
        lines << line
      elsif c =~ /\w/
        line.rhyme = c.downcase
      else
        raise 'Invalid format'
      end
    end

    self.new(lines, {})
  end

  def initialize(lines, known_rhymes)
    @lines = lines
    @known_rhymes = known_rhymes
  end

  # Returns true if the format matches these phonetics
  def matches?(phonetics)
    # Make sure the word doesn't mave more syllables than the line
    return false unless phonetics.syllables.size <= current_line.syllables.size

    # Make sure syllables rhyme (if a rhyme was defined)
    phonetics.syllables.each_with_index do |syl, i|
      return false unless syl.sounds_like?(current_line.syllables[i])
    end

    # If the word completes the line, make sure it doesn't match another rhyming word
    if ends_line?(phonetics) && @known_rhymes.include?(current_line.rhyme)
      if @known_rhymes[current_line.rhyme].include?(phonetics.word)
        return false
      end
    end

    true
  end

  def ends_line?(phonetics)
    return phonetics.syllables.size == current_line.syllables.size
  end

  # Returns a new format with these phonetics applied
  def trim_format(phonetics)
    raise 'oops' unless matches?(phonetics)

    new_lines = @lines.map(&:clone)
    new_rhymes = @known_rhymes.clone
    last_line = new_lines.first

    phonetics.syllables.each do |syl|
      raise 'oops' if last_line.syllables.shift.nil?
    end

    if last_line.syllables.empty?
      # Advance line
      new_lines.shift

      # Update syllables with pronunciation only if it is the first time this rhyme has occurred
      unless new_rhymes.include?(last_line.rhyme)
        # Select lines that rhyme
        new_lines.select{ |l| l.rhyme == last_line.rhyme }.each do |line|
          start = line.syllables.size - phonetics.rhyme_syllables.size

          # Update format syllables with phones
          phonetics.rhyme_syllables.each_with_index do |syl, i|
            format_syl = line.syllables[start + i]
            format_syl.update_phones(syl.phones)
          end
        end
      end

      # Add the word to the list of rhyming words to prevent re-using rhyme words
      new_rhymes[last_line.rhyme] ||= Set.new
      new_rhymes[last_line.rhyme].add(phonetics.word)
    end

    PoemFormat.new(new_lines, new_rhymes)
  end

  def eof?
    (current_line.nil? || current_line.syllables.size == 0)
  end

  def current_line
    @lines.first
  end
end