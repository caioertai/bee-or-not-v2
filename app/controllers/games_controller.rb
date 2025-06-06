class GamesController < ApplicationController
  before_action :set_game, only: [ :show ]

  def new
    @game = Game.new
  end

  def create
    @game = Game.create!
    @game.add_player!(current_player)

    # Start the first guess
    redirect_to new_game_guess_path(@game)
  end

  def show
    @players = @game.players.order(:created_at)
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end
end
