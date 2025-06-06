class GamesController < ApplicationController
  before_action :set_game, only: [ :show, :join, :join_game ]

  def new
    @game = Game.new
  end

  def create
    @game = Game.create!
    @game.add_player!(current_player)

    # Start the first guess
    redirect_to new_game_guess_path(@game)
  end

  def show
    @players = @game.players.order(:created_at)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def join
    @player_name = params[:player_name] || current_player.name
  end

  def join_game
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
    @game = Game.find(params[:id])
  end
end
