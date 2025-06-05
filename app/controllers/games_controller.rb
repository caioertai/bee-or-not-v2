class GamesController < ApplicationController
  def new
    @game = Game.new
  end

  def create
    @game = Game.create!

    # Start the first round
    redirect_to new_game_round_path(@game)
  end

  def show
    @game = Game.find(params[:id])
    @total_headlines = Headline.count
  end
end
