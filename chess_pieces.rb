# encoding: utf-8
class Piece
  DIRECTIONS = [[1, 1], [1, -1], [-1, -1], [-1, 1],
                [0, 1], [1, 0], [0, -1], [-1, 0]]

  attr_accessor :position
  attr_reader :color, :symbol

  def initialize(color, symbol, position)
    @color = color
    @symbol = symbol
    @position = position
  end

  private

  # checks if pos is on board
  def on_board?(pos)
    pos.all? {|p| p >= 0 && p <= 7}
  end

  # removes all spaces occupied by pieces of the same color
  def invalid_moves(moves, board)
    invalid = []
    moves.each do |y, x|
      unless board[y][x].nil?
        invalid << [y,x] if board[y][x].color == @color
      end
    end
    invalid
  end

  # recursively finds all possible moves in a given direction
  # and returns an array
  def moves_in_direction(cur_pos, direction, board, positions = [])
    y, x = cur_pos
    dir_y, dir_x = direction
    new_pos = [y + dir_y, x + dir_x]

    positions << new_pos if on_board?(new_pos)
    if !on_board?(new_pos) || !board[new_pos[0]][new_pos[1]].nil?
      return positions
    else
      moves_in_direction(new_pos, direction, board, positions)
    end
  end
end

# Specific Piece subclasses

class King < Piece
  def possible_moves(board)
    moves = []
    DIRECTIONS.each do |dir|
      moves << moves_in_direction(@position, dir, board)
    end
    moves.flatten!(1).reject! do |y,x|
      (y - @position[0]).abs > 1 || (x - @position[1]).abs > 1
    end
    moves - invalid_moves(moves, board)
  end
end

class Queen < Piece
  def possible_moves(board)
    moves = []
    DIRECTIONS.each do |dir|
      moves << moves_in_direction(@position, dir, board)
    end
    moves.flatten!(1)
    moves - invalid_moves(moves, board)
  end
end

class Bishop < Piece
  def possible_moves(board)
    moves = []
    DIRECTIONS.select {|y,x| (y + x).abs != 1}.each do |dir|
      moves << moves_in_direction(@position, dir, board)
    end
    moves.flatten!(1)
    moves - invalid_moves(moves, board)
  end
end

class Knights < Piece
  KNIGHT_MOVES = [[2, 1], [2, -1], [-1, 2], [1, -2],
                  [1, 2], [-1, 2], [-2, 1], [-2, -1]]

  def possible_moves(board)
    moves = []
    y, x = @position

    KNIGHT_MOVES.each do |dy, dx|
      pos = [y + dy, x + dx]
      moves << pos if on_board?(pos)
    end
    moves - invalid_moves(moves, board)
  end
end

class Rook < Piece
  def possible_moves(board)
    moves = []
    DIRECTIONS.select {|y,x| (y + x).abs == 1}.each do |dir|
      moves << moves_in_direction(@position, dir, board)
    end
    moves.flatten!(1)
    moves - invalid_moves(moves, board)
  end
end

class Pawn < Piece
  def possible_moves(board)
    y, x = @position
    moves = []
    @color == :black ? y += 1 : y -= 1

    moves << [y, x] if board[y][x].nil?
    moves << [y, x + 1] unless board[y][x + 1].nil?
    moves << [y, x - 1] unless board[y][x - 1].nil?

    moves.reject! {|pos| !on_board?(pos)}

    moves << first_move if is_first? && board[first_move[0]][first_move[1]].nil?
    moves - invalid_moves(moves, board)
  end

  private

  def first_move
    if @position[0] == 1
      [@position[0] + 2, @position[1]] # moves black pawn
    else
      [@position[0] - 2, @position[1]] # moves white pawn
    end
  end

  def is_first?
    (@position[0] == 1 && @color == :black) || (@position[0] == 6 && @color ==  :white)
  end
end