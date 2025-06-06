require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "should be valid with default score" do
    game = Game.new
    assert game.valid?
    assert_equal 0, game.score
  end

  test "should have many rounds" do
    game = games(:active_game)
    assert_respond_to game, :rounds
    assert game.rounds.count > 0
  end

  test "should create first round after creation" do
    assert_difference "Round.count", 1 do
      Game.create!
    end
  end

  test "total_rounds should return count of completed rounds" do
    game = games(:active_game)
    # Total rounds should count rounds that have guesses
    expected_total = game.rounds.joins(:guesses).distinct.count
    assert_equal expected_total, game.total_rounds
  end

  test "correct_rounds should return count of correct rounds" do
    game = games(:active_game)
    expected_correct = game.rounds.joins(:guesses).where(guesses: { correct: true }).distinct.count
    assert_equal expected_correct, game.correct_rounds
  end

  test "accuracy_percentage should calculate correctly" do
    game = games(:active_game)
    total = game.total_rounds
    correct = game.correct_rounds

    if total > 0
      expected = (correct.to_f / total * 100).round(1)
      assert_equal expected, game.accuracy_percentage
    else
      assert_equal 0, game.accuracy_percentage
    end
  end

  test "accuracy_percentage should return 0 for no completed rounds" do
    game = games(:new_game)
    assert_equal 0, game.accuracy_percentage
  end

  test "current_round should return incomplete round or create new one" do
    game = games(:new_game)
    round = game.current_round
    assert_instance_of Round, round
    assert_equal game, round.game
  end

  test "increment_score! should increase score by 1" do
    game = games(:new_game)
    original_score = game.score
    game.increment_score!
    assert_equal original_score + 1, game.reload.score
  end
end
