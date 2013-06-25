# encoding: utf-8

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
                            [1,4],[1,5],[1,6],[1,7]], '♙'],
                  :rook => [[[0,0],[0,7]], '♖'	],
                  :knight => [[[0,1],[0,6]], '♘']	,
                  :bishop => [[[0,2],[0,5]], '♗'],
                  :queen => [[[0,3]], '♕'	],
                  :king => [[[0,4]], '♔']
  }

  attr_accessor :board, :white_turn

  def initialize
    @board = Array.new(8) {Array.new(8)}
    @turn = :white
    @moves = 0
    build_board
  end

  def print_board
    print "   "
    ('a'..'h').each {|c| print " #{c} "} # print column headers
    print "\n"
    @board.each_with_index do |row, row_ind|
      print "#{(row_ind - BOARD_LENGTH).abs}  " # print row numbers
      row.each_with_index do |elem, col_ind|
        if elem.nil?  # print empty squares
           ((col_ind+row_ind).odd? ? (print " ▢ ") : (print " ▩ ") )
        else # print pieces
          (print " #{elem.symbol} ")
        end
      end
      puts "\n"
    end
  end

  def change_turn
    @turn = (@turn == :white ? :black : :white)
    @moves += 1
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

end