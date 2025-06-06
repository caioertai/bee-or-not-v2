class GamesController < ApplicationController
  def new
    @game = Game.new
  end

  def create
    @game = Game.create!

    # Start the first guess
    redirect_to new_game_guess_path(@game)
  end

  def show
    @game = Game.find(params[:id])
  end
end
