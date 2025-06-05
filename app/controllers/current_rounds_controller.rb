class CurrentRoundsController < ApplicationController
  before_action :ensure_game_exists
  before_action :load_game

  def show
    @round = create_new_round
    @game = load_game
  end

  def guess
    @round = create_new_round
    @game = load_game

    user_guess = params[:guess]

    # Validate guess
    unless %w[real fake].include?(user_guess)
      flash[:error] = "Invalid guess. Please select Real or Fake."
      return redirect_to game_current_round_path(params[:game_id])
    end

    # Process the guess
    @round = @round.make_guess(user_guess)

    # Update session with game progress
    session[:total_rounds] = (session[:total_rounds] || 0) + 1
    session[:score] = (session[:score] || 0) + (@round.correct ? 1 : 0)

    # Update game object with new stats
    @game = Game.new(
      id: @game.id,
      score: session[:score],
      total_rounds: session[:total_rounds],
      created_at: @game.created_at
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("round-content", partial: "current_rounds/feedback", locals: { round: @round, game: @game }),
          turbo_stream.replace("game-stats", partial: "games/stats", locals: { game: @game })
        ]
      end
      format.html { redirect_to game_current_round_path(params[:game_id]) }
    end
  end

  private

  def ensure_game_exists
    return if session[:game_id]

    redirect_to new_game_path, alert: "Please start a new game first."
  end

  def load_game
    @game ||= Game.new(
      id: session[:game_id],
      score: session[:score] || 0,
      total_rounds: session[:total_rounds] || 0,
      created_at: Time.current
    )
  end

  def create_new_round
    # Store the current headline in session to maintain consistency during guess
    if params[:action] == "guess" && session[:current_headline_id]
      headline = Headline.find(session[:current_headline_id])
    else
      headline = Headline.order("RANDOM()").first
      session[:current_headline_id] = headline.id
    end

    Round.new(
      id: SecureRandom.uuid,
      game_id: @game.id,
      headline: headline,
      user_guess: nil,
      correct: nil,
      completed_at: nil
    )
  end
end
