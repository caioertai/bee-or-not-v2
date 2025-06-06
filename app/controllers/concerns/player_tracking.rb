module PlayerTracking
  extend ActiveSupport::Concern

  included do
    before_action :ensure_current_player
  end

  private

  def current_player
    @current_player ||= find_or_create_player
  end

  def find_or_create_player
    player_uuid = cookies[:player_uuid]

    if player_uuid.present?
      player = Player.find_by(uuid: player_uuid)
      return player if player
    end

    create_new_player
  end

  def create_new_player
    player = Player.create!(name: generate_random_name)
    cookies[:player_uuid] = { value: player.uuid, expires: 30.days.from_now }
    player
  end

  def generate_random_name
    adjectives = %w[Swift Clever Bold Bright Quick Sharp Wise Cool Smart Fast]
    animals = %w[Fox Wolf Eagle Tiger Bear Lion Hawk Lynx Owl Falcon]
    "#{adjectives.sample} #{animals.sample} #{rand(100..999)}"
  end

  def ensure_current_player
    current_player
  end
end
