class GamePlayer < ApplicationRecord
  belongs_to :game
  belongs_to :player

  validates :game, presence: true
  validates :player, presence: true
  validates :game_id, uniqueness: { scope: :player_id }
end
