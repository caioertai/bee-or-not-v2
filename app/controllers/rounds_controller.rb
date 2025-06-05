class RoundsController < ApplicationController
  before_action :load_game
  before_action :load_round, only: [ :show ]

  def new
    @round = @game.rounds.build
    @headline = Headline.order("RANDOM()").first
  end

  def create
    @headline = Headline.find(params[:round][:headline_id])
    @round = @game.rounds.build(
      headline: @headline,
      user_guess: params[:user_guess]
    )

    if @round.save
      @game.increment_score! if @round.correct?

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("round-content", partial: "feedback", locals: { round: @round, game: @game }),
            turbo_stream.replace("game-stats", partial: "games/stats", locals: { game: @game })
          ]
        end
        format.html { redirect_to game_round_path(@game, @round) }
      end
    else
      redirect_to new_game_round_path(@game), alert: "Please select Real or Fake."
    end
  end

  def show
    # Show the result of a completed round
  end

  private

  def load_game
    @game = Game.find(params[:game_id])
  end

  def load_round
    @round = @game.rounds.find(params[:id])
  end
end
