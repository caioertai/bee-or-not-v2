module PlayerTracking
  extend ActiveSupport::Concern

  included do
    before_action :ensure_current_player
  end

  private

  def current_player
    @current_player ||= find_or_create_player_from_cookie
  end

  def find_or_create_player_from_cookie
    player_uuid = cookies[:player_uuid]

    if player_uuid.present?
      player = Player.find_by(uuid: player_uuid)
      return player if player
    end

    # Create new player with UUID and set cookie
    player = Player.create!(
      uuid: SecureRandom.uuid,
      name: RandomNameGenerator.generate
    )
    cookies[:player_uuid] = { value: player.uuid, expires: 30.days.from_now }
    player
  end

  def ensure_current_player
    current_player
  end
end
