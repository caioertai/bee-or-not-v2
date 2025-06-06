require "test_helper"

class RoundTest < ActiveSupport::TestCase
  test "should belong to game and headline" do
    round = rounds(:round_with_correct_guess)
    assert_respond_to round, :game
    assert_respond_to round, :headline
    assert_instance_of Game, round.game
    assert_instance_of Headline, round.headline
  end

  test "should have many guesses" do
    round = rounds(:round_with_correct_guess)
    assert_respond_to round, :guesses
    assert round.guesses.any?
  end

  test "current_guess should return the latest guess" do
    round = rounds(:round_with_correct_guess)
    guess = round.current_guess
    assert_instance_of Guess, guess
    assert_equal guesses(:correct_real_guess), guess
  end

  test "completed? should return true when round has guesses" do
    round = rounds(:round_with_correct_guess)
    assert round.completed?
  end

  test "completed? should return false when round has no guesses" do
    round = rounds(:current_round)
    assert_not round.completed?
  end

  test "correct? should delegate to current_guess" do
    correct_round = rounds(:round_with_correct_guess)
    assert correct_round.correct?

    incorrect_round = rounds(:round_with_incorrect_guess)
    assert_not incorrect_round.correct?
  end
end
