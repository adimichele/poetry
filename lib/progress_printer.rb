class ProgressPrinter
  # initialize with an open file
  def initialize(file, size=50)
    @file = file
    @size = size
    @last_dots = -1
  end

  def print_progress
    dots = ((@file.pos.to_f / @file.size.to_f) * @size).to_i
    unless dots == @last_dots  # Avoid re-printing the same thing over and over
      print "\r#{File.basename(@file.path)}\t[#{('=' * dots)}#{(' ' * (@size - dots))}]"
      @last_dots = dots
    end
  end
end