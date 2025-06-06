class GuessesController < ApplicationController
  before_action :set_game

  def new
    @guess = @game.current_round.guesses.build
  end

  def create
    @guess = @game.current_round.guesses.build(guess_params)

    if @guess.save
      # Broadcast guess to all players in the game
      broadcast_guess_to_players(@guess)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("round-content", partial: "guesses/feedback", locals: { guess: @guess }),
            turbo_stream.replace("game-stats", partial: "games/stats", locals: { game: @game })
          ]
        end
        format.html do
          @game.completed? ? redirect_to(@game) : redirect_to(new_game_guess_path(@game))
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end


  private

  def set_game
    @game = Game.includes(current_round: [ :headline, :guesses ]).find(params[:game_id])

    # Ensure current player is part of the game
    @game.add_player!(current_player) unless @game.players.include?(current_player)

    return unless @game.current_round.nil?
    return redirect_to game_path(@game) if @game.completed?

    @game.create_next_round!
  end

  def guess_params
    params.require(:guess).permit(:real)
  end

  def broadcast_guess_to_players(guess)
    ActionCable.server.broadcast("game_#{@game.id}", {
      type: "guess_made",
      player_name: current_player.name,
      guess: guess.guess_text,
      correct: guess.correct?,
      round_id: guess.round.id
    })
  end
end
