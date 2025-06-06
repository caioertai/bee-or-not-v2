class GuessesController < ApplicationController
  before_action :set_game

  def new
    @guess = @game.current_round.guesses.build
  end

  def create
    @guess = @game.current_round.guesses.build(guess_params)

    if @guess.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("round-content", partial: "guesses/feedback", locals: { guess: @guess, game: @game }),
            turbo_stream.replace("game-stats", partial: "games/stats", locals: { game: @game })
          ]
        end
        format.html { redirect_to new_game_guess_path(@game) }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end


  private

  def set_game
    @game = Game.includes(current_round: [ :headline, :guesses ]).find(params[:game_id])
    @game.create_next_round! if @game.current_round.nil?
  end

  def guess_params
    # Convert "real" to true, "fake" to false for the real boolean attribute
    real_value = params.require(:guess)[:user_guess] == "real"
    { real: real_value }
  end
end
