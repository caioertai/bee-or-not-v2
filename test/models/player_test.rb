require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  test "player requires name" do
    player = Player.new(uuid: "test-uuid")
    assert_not player.valid?
    assert_includes player.errors[:name], "can't be blank"
  end

  test "player requires uuid" do
    player = players(:alice)
    player.uuid = nil
    assert_not player.valid?
    assert_includes player.errors[:uuid], "can't be blank"
  end

  test "uuid must be unique" do
    existing_player = players(:alice)
    player = Player.new(name: "Test Player", uuid: existing_player.uuid)
    assert_not player.valid?
    assert_includes player.errors[:uuid], "has already been taken"
  end

  test "uuid is generated automatically on create" do
    player = Player.create!(name: "Test Player")
    assert_not_nil player.uuid
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/, player.uuid)
  end

  test "player can have multiple games" do
    player = players(:alice)
    assert_equal 2, player.games.count
    assert_includes player.games, games(:one)
    assert_includes player.games, games(:active_game)
  end
end
