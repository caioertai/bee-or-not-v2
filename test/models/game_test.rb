require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "should be valid" do
    game = Game.new
    assert game.valid?
  end

  test "score should return count of correct guesses" do
    game = games(:active_game)
    expected_score = game.guesses.where(correct: true).count
    assert_equal expected_score, game.score
  end

  test "score should return 0 for new game" do
    game = games(:new_game)
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

  test "accuracy_ratio should calculate correctly" do
    game = games(:active_game)
    total = game.total_rounds
    correct = game.correct_rounds

    if total > 0
      expected = correct.to_f / total
      assert_equal expected, game.accuracy_ratio
    else
      assert_equal 0, game.accuracy_ratio
    end
  end

  test "accuracy_ratio should return 0 for no completed rounds" do
    game = games(:new_game)
    assert_equal 0, game.accuracy_ratio
  end

  test "should have current_round association" do
    game = games(:new_game)
    assert_respond_to game, :current_round
    # current_round association should return the round with no guesses
    assert_not_nil game.current_round
    assert_equal rounds(:current_round), game.current_round
  end

  test "create_next_round! should create a new round" do
    game = Game.create!
    # Remove the auto-created round to test create_next_round! cleanly
    game.rounds.destroy_all

    assert_difference "game.rounds.count", 1 do
      round = game.create_next_round!
      assert_instance_of Round, round
      assert_equal game, round.game
      assert_not_nil round.headline
    end
  end

  test "#create_next_round! should set the current_round to the new round" do
    game = Game.create!
    game.rounds.destroy_all
    game.create_next_round!
    assert_equal game.current_round, game.rounds.last
  end

  test "should have many guesses through rounds" do
    game = games(:active_game)
    assert_respond_to game, :guesses
    assert game.guesses.any?
  end
end
