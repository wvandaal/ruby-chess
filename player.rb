class Player
  POSITIONS = Hash[('a'..'h').to_a.zip((0..7).to_a)]

  attr_accessor :name, :color

  def initialize(name, color)
    @name = name
    @color = color
  end

  def input_move
    begin
      print "Make a move (e.g. e6 f4): "
      input = gets.chomp.downcase.split(" ")
      move = process_move(input)
    rescue ArgumentError => e
      puts "Invalid move: #{e}"
      retry
    end
  end

  def process_move(input)
    moves = []
    input.each {|e| moves << e.split('')}
    if is_valid_position?(moves)
      moves.map {|y,x| [POSITIONS[y], x.to_i - 1]}
    end
  end

  def is_valid_position?(positions)
    raise ArgumentError.new "Your answer was too long/short. Input a move in the form: a1 b2." if positions.flatten.length != 4
    raise ArgumentError.new "You entered the same position twice. Enter two valid tiles." if positions.first == positions.last
    positions.each do |y, x|
      if !('a'..'h').include?(y) || !(1..8).include?(x.to_i)
        p y, y.to_sym
        p x, x.to_i
        raise ArgumentError.new "You entered a position that is not on the board.\nEnter two tiles in the range of [a-h] and [1-8]."
      end
    end
    return true
  end
end