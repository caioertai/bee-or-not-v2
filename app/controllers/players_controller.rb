class PlayersController < ApplicationController
  before_action :set_game

  def new
    @player_name = params[:player_name] || current_player.name
  end

  def create
    if params[:player_name].present?
      current_player.update!(name: params[:player_name])
    end

    @game.add_player!(current_player)

    respond_to do |format|
      format.html { redirect_to new_game_guess_path(@game) }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("players_list", partial: "games/players_list", locals: { players: @game.players.order(:created_at) }),
          turbo_stream.append("flash_messages", partial: "shared/flash_message", locals: { type: "notice", message: "#{current_player.name} joined the game!" })
        ]
      end
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end
end
