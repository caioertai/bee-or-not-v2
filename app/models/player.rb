class Player < ApplicationRecord
  has_many :game_players, dependent: :destroy
  has_many :games, through: :game_players

  validates :uuid, presence: true, uniqueness: true
  validates :name, presence: true

  before_validation :generate_uuid, on: :create

  private

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
