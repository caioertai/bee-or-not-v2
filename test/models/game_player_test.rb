require "test_helper"

class GamePlayerTest < ActiveSupport::TestCase
  test "requires game and player" do
    game_player = GamePlayer.new
    assert_not game_player.valid?
    assert_includes game_player.errors[:game], "can't be blank"
    assert_includes game_player.errors[:player], "can't be blank"
  end

  test "prevents duplicate game-player combinations" do
    existing = game_players(:alice_game_one)
    duplicate = GamePlayer.new(game: existing.game, player: existing.player)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:game_id], "has already been taken"
  end

  test "allows same player in different games" do
    alice = players(:alice)
    new_game = Game.create!
    game_player = GamePlayer.new(game: new_game, player: alice)
    assert game_player.valid?
  end

  test "allows different players in same game" do
    game = games(:one)
    new_player = Player.create!(uuid: SecureRandom.uuid, name: "Charlie Brown")
    game_player = GamePlayer.new(game: game, player: new_player)
    assert game_player.valid?
  end
end
