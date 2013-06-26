# encoding: utf-8
require 'colorize'

require './chess_pieces.rb'

class Board
  BOARD_LENGTH = 8

  # format: piece => [[positions], symbol]
  WHITE_PIECES = {:pawn => [[[6,0],[6,1],[6,2],[6,3],
                            [6,4],[6,5],[6,6],[6,7]], '♟'],
                  :rook => [[[7,0],[7,7]], '♜'],
                  :knight => [[[7,1],[7,6]], '♞'],
                  :bishop => [[[7,2],[7,5]], '♝'],
                  :queen => [[[7,3]], '♛'],
                  :king => [[[7,4]], '♚']
                }
  BLACK_PIECES = {
                  :pawn => [[[1,0],[1,1],[1,2],[1,3],
                            [1,4],[1,5],[1,6],[1,7]], '♟'],
                  :rook => [[[0,0],[0,7]], '♜'	],
                  :knight => [[[0,1],[0,6]], '♞']	,
                  :bishop => [[[0,2],[0,5]], '♝'],
                  :queen => [[[0,3]], '♛'	],
                  :king => [[[0,4]], '♚']
                }

  attr_accessor :board

  def initialize
    @board = Array.new(8) {Array.new(8)}
    @moves = []
    build_board
  end

  def print_board
    `clear`
    print "   "
    ('a'..'h').each {|c| print " #{c}  "} # print column headers
    print "\n"
    @board.each_with_index do |row, row_ind|
      print "#{(row_ind - BOARD_LENGTH).abs}  " # print row numbers
      row.each_with_index do |elem, col_ind|
        if elem.nil?  # print empty squares
           print "    ".colorize(:background => ((col_ind+row_ind).odd? ? :blue : :light_red))
        else # print pieces
          print " #{elem.symbol}  ".colorize(:color => elem.color, :background => ((col_ind+row_ind).odd? ? :blue : :light_red))
        end
      end
      puts ""
    end
    puts ""
  end

  def make_move(move)
    py, px, dy, dx = move.flatten # piece y,x ; destination y,x
    piece = @board[py][px]
    raise ArgumentError.new "There is no piece there." if piece.nil?
    unless piece.possible_moves(@board).include?([dy,dx])
      raise ArgumentError.new "That is not a valid move for this piece."
    end
    this_move = Move.new([py, px], [dy, dx])

    @board[py][px] = nil
    this_move.captured = @board[dy][dx] unless @board[dy][dx].nil?
    piece.position = [dy,dx]
    @moves << this_move
    @board[dy][dx] = piece
  end

  def undo_move
    move = @moves.pop
    y, x = move.final
    prev_y, prev_x = move.initial
    captured = (move.captured.nil? ? nil : move.captured)

    @board[y][x].position = [prev_y, prev_x]
    @board[prev_y][prev_x] = @board[y][x]
    @board[y][x] = captured
  end

  # returns true if given color is in check
  def check?(color)
    pieces = get_pieces
    king = pieces.select {|piece| piece.color == color && piece.is_a?(King)}[0]
    opponents = pieces.reject {|piece| piece.color == color}
    opp_moves = all_possible_moves(opponents)
    opp_moves.values.flatten(1).include?(king.position)
  end

  # Note: assumes check?(color) has been called
  def checkmate?(color)
    checkmate = true
    pieces = get_pieces
    allies = pieces.select {|piece| piece.color == color}
    ally_moves = all_possible_moves(allies)


    ally_moves.each do |piece, moves_array|
      pos = piece.position
      moves_array.each do |move|
        make_move([pos, move])
        checkmate = false unless check?(color)
        undo_move
      end
    end
    checkmate
  end

  private

  def build_board
    WHITE_PIECES.each do |piece, values|
      case piece
      when :king
        build_pieces(:white, values[1], values[0], King)
      when :queen
        build_pieces(:white, values[1], values[0], Queen)
      when :bishop
        build_pieces(:white, values[1], values[0], Bishop)
      when :knight
        build_pieces(:white, values[1], values[0], Knights)
      when :rook
        build_pieces(:white, values[1], values[0], Rook)
      when :pawn
        build_pieces(:white, values[1], values[0], Pawn)
      end
    end

    BLACK_PIECES.each do |piece, values|
      case piece
      when :king
        build_pieces(:black, values[1], values[0], King)
      when :queen
        build_pieces(:black, values[1], values[0], Queen)
      when :bishop
        build_pieces(:black, values[1], values[0], Bishop)
      when :knight
        build_pieces(:black, values[1], values[0], Knights)
      when :rook
        build_pieces(:black, values[1], values[0], Rook)
      when :pawn
        build_pieces(:black, values[1], values[0], Pawn)
      end
    end
  end

  def build_pieces(color, symbol, positions, klass)
    positions.each do |y, x|
      @board[y][x] = klass.new(color, symbol, [y, x])
    end
  end

  # returns array of every piece on the board
  def get_pieces
    @board.flatten.reject {|piece| piece.nil?}
  end

  # returns hash of all possible moves for each piece
  def all_possible_moves(pieces)
    all_moves = {}
    pieces.each do |piece|
      all_moves[piece] = piece.possible_moves(@board)
    end
    all_moves
  end

end


# Move class to enable easy undo_move functionality
# stores initial position, final position, and the
# captured piece (if any)
class Move
  attr_accessor :initial, :final, :captured

  def initialize(initial, final, captured = nil)
    @initial = initial
    @final = final
    @captured = captured
  end
end
