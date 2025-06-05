require "test_helper"

class RoundTest < ActiveSupport::TestCase
  test "create_for_game should create a round with headline" do
    round = Round.create_for_game("test-game-id")

    assert_not_nil round.id
    assert_equal "test-game-id", round.game_id
    assert_not_nil round.headline
    assert_instance_of Headline, round.headline
    assert_nil round.user_guess
    assert_nil round.correct
    assert_nil round.completed_at
  end

  test "make_guess should mark correct guess for real headline" do
    headline = headlines(:real_headline)
    round = Round.new(id: "test", game_id: "game", headline: headline, user_guess: nil, correct: nil, completed_at: nil)

    result_round = round.make_guess("real")

    assert_equal "real", result_round.user_guess
    assert result_round.correct
    assert_not_nil result_round.completed_at
  end

  test "make_guess should mark incorrect guess for real headline" do
    headline = headlines(:real_headline)
    round = Round.new(id: "test", game_id: "game", headline: headline, user_guess: nil, correct: nil, completed_at: nil)

    result_round = round.make_guess("fake")

    assert_equal "fake", result_round.user_guess
    assert_not result_round.correct
    assert_not_nil result_round.completed_at
  end

  test "make_guess should mark correct guess for fake headline" do
    headline = headlines(:fake_headline)
    round = Round.new(id: "test", game_id: "game", headline: headline, user_guess: nil, correct: nil, completed_at: nil)

    result_round = round.make_guess("fake")

    assert_equal "fake", result_round.user_guess
    assert result_round.correct
    assert_not_nil result_round.completed_at
  end

  test "completed? should return false for incomplete round" do
    round = Round.new(id: "test", game_id: "game", headline: headlines(:real_headline), user_guess: nil, correct: nil, completed_at: nil)
    assert_not round.completed?
  end

  test "completed? should return true for completed round" do
    round = Round.new(id: "test", game_id: "game", headline: headlines(:real_headline), user_guess: "real", correct: true, completed_at: Time.current)
    assert round.completed?
  end

  test "guess_text should capitalize user guess" do
    round = Round.new(id: "test", game_id: "game", headline: headlines(:real_headline), user_guess: "real", correct: nil, completed_at: nil)
    assert_equal "Real", round.guess_text
  end

  test "result_text should return empty for incomplete round" do
    round = Round.new(id: "test", game_id: "game", headline: headlines(:real_headline), user_guess: nil, correct: nil, completed_at: nil)
    assert_equal "", round.result_text
  end

  test "result_text should return correct message for correct guess" do
    headline = headlines(:real_headline)
    round = Round.new(id: "test", game_id: "game", headline: headline, user_guess: "real", correct: true, completed_at: Time.current)
    assert_includes round.result_text, "Correct! This headline was real."
  end

  test "result_text should return wrong message for incorrect guess" do
    headline = headlines(:real_headline)
    round = Round.new(id: "test", game_id: "game", headline: headline, user_guess: "fake", correct: false, completed_at: Time.current)
    assert_includes round.result_text, "Wrong! This headline was actually real."
  end

  test "result_class should return appropriate CSS class" do
    correct_round = Round.new(id: "test", game_id: "game", headline: headlines(:real_headline), user_guess: "real", correct: true, completed_at: Time.current)
    assert_equal "text-green-600", correct_round.result_class

    incorrect_round = Round.new(id: "test", game_id: "game", headline: headlines(:real_headline), user_guess: "fake", correct: false, completed_at: Time.current)
    assert_equal "text-red-600", incorrect_round.result_class
  end
end
