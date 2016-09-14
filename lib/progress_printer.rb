class ProgressPrinter
  # initialize with an open file
  def initialize(file, size=50)
    @file = file
    @size = size
  end

  def print_progress
    dots = ((@file.pos.to_f / @file.size.to_f) * @size).to_i
    print "\r#{File.basename(@file.path)}\t[#{('=' * dots)}#{(' ' * (@size - dots))}]"
  end
end