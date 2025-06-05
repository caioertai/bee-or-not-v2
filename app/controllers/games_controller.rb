class GamesController < ApplicationController
  def new
    # Display game setup/start page
  end

  def create
    # Initialize a new game session
    session[:game_id] = SecureRandom.uuid
    session[:score] = 0
    session[:total_rounds] = 0

    game = Game.create
    session[:game_id] = game.id

    redirect_to game_current_round_path(game.id)
  end

  def show
    @game = load_game
    @total_headlines = Headline.count
  end

  private

  def load_game
    return redirect_to new_game_path unless session[:game_id]

    # Create game object with session data
    Game.new(
      id: session[:game_id],
      score: session[:score] || 0,
      total_rounds: session[:total_rounds] || 0,
      created_at: Time.current
    )
  end
end
