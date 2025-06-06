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
            turbo_stream.replace("round-content", partial: "guesses/feedback", locals: { guess: @guess }),
            turbo_stream.replace("game-stats", partial: "games/stats", locals: { game: @game })
          ]
        end
        format.html do
          if @game.completed?
            redirect_to game_path(@game)
          else
            redirect_to new_game_guess_path(@game)
          end
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end


  private

  def set_game
    @game = Game.includes(current_round: [ :headline, :guesses ]).find(params[:game_id])

    return unless @game.current_round.nil?
    return redirect_to game_path(@game) if @game.completed?

    @game.create_next_round!
  end

  def guess_params
    params.require(:guess).permit(:real)
  end
end
