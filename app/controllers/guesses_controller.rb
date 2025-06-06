class GuessesController < ApplicationController
  before_action :set_game

  def new
    @round = @game.current_round
    @guess = @round.guesses.build
  end

  def create
    @round = @game.current_round
    @guess = @round.guesses.build(guess_params)

    if @guess.save
      @game.increment_score! if @guess.correct?

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
    @game = Game.find(params[:game_id])
  end

  def guess_params
    params.require(:guess).permit(:user_guess)
  end
end
