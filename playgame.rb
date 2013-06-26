require './chess_pieces'
require './game_board'
require './player'

class ChessGame

  attr_reader :player1, :player2, :board, :turn, :moves

  def initialize(name1, name2)
    @player1 = Player.new(name1, :white)
    @player2 = Player.new(name2, :black)
    @board = Board.new
    @turn = :white
  end

  # Main game-playing function
  def play_game
    greeting

    until @board.checkmate?(@turn)
      puts "#{@turn.capitalize} is in Check." if @board.check?(@turn)

      begin
        @board.print_board
        move = (@turn == :white ? @player1.input_move : @player2.input_move)

        if move == "undo"
          @board.undo_move
        else
        piece = get_piece(move[0])
        if piece.color != @turn
          raise ArgumentError.new "That is not your piece."
        end
        @board.make_move(move)

        if @board.check?(piece.color)
          raise ArgumentError.new "You are still in check"
          undo_move
        end
      rescue ArgumentError => e
        puts "Error: #{e}"
        retry
      end
      change_turn
    end
    @board.print_board
    goodbye
  end

  private

  def change_turn
    @turn = (@turn == :white ? :black : :white)
  end

  def get_piece(position)
    @board.board[position[0]][position[1]]
  end

  def greeting
    puts "Welcome to Chess."
    puts "Team black will be #{@player1.name}."
    puts "Team white will be #{@player2.name}"
  end

  def goodbye
    if @turn == :white
      (puts "#{@player1.name} wins!")
    else
      (puts "#{@player2.name} wins!")
    end
  end
end