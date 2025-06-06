class Player < ApplicationRecord
  has_many :game_players, dependent: :destroy
  has_many :games, through: :game_players

  validates :uuid, presence: true, uniqueness: true
  validates :name, presence: true
end
