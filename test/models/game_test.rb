require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "create should generate a game with default values" do
    game = Game.create

    assert_not_nil game.id
    assert_equal 0, game.score
    assert_equal 0, game.total_rounds
    assert_not_nil game.created_at
  end

  test "increment_score! should increase score by 1" do
    game = Game.create
    new_game = game.increment_score!

    assert_equal 1, new_game.score
    assert_equal game.total_rounds, new_game.total_rounds
  end

  test "increment_rounds! should increase total_rounds by 1" do
    game = Game.create
    new_game = game.increment_rounds!

    assert_equal game.score, new_game.score
    assert_equal 1, new_game.total_rounds
  end

  test "accuracy_percentage should return 0 for no rounds" do
    game = Game.create
    assert_equal 0, game.accuracy_percentage
  end

  test "accuracy_percentage should calculate correctly" do
    game = Game.new(id: "test", score: 3, total_rounds: 4, created_at: Time.current)
    assert_equal 75.0, game.accuracy_percentage
  end

  test "accuracy_percentage should handle perfect score" do
    game = Game.new(id: "test", score: 5, total_rounds: 5, created_at: Time.current)
    assert_equal 100.0, game.accuracy_percentage
  end
end
