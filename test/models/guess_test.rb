require "test_helper"

class GuessTest < ActiveSupport::TestCase
  test "should belong to round" do
    guess = guesses(:correct_real_guess)
    assert_respond_to guess, :round
    assert_instance_of Round, guess.round
  end

  test "should validate user_guess presence and inclusion" do
    round = rounds(:current_round)
    guess = Guess.new(round: round)

    # Should require user_guess
    assert_not guess.valid?
    assert_includes guess.errors[:user_guess], "can't be blank"

    # Should only allow 'real' or 'fake'
    guess.user_guess = "invalid"
    assert_not guess.valid?
    assert_includes guess.errors[:user_guess], "is not included in the list"

    # Should be valid with correct values
    guess.user_guess = "real"
    assert guess.valid?
  end

  test "correct? should return true when guess matches headline reality" do
    round = rounds(:current_round)
    real_headline = round.headline  # This is real_headline from fixtures

    # Correct guess for real headline
    correct_guess = Guess.new(round: round, user_guess: "real")
    assert correct_guess.correct?

    # Incorrect guess for real headline
    incorrect_guess = Guess.new(round: round, user_guess: "fake")
    assert_not incorrect_guess.correct?
  end

  test "guess_text should capitalize user_guess" do
    guess = guesses(:correct_real_guess)
    assert_equal "Real", guess.guess_text
  end

  test "result_text should return appropriate message" do
    correct_guess = guesses(:correct_real_guess)
    assert_includes correct_guess.result_text, "Correct! This headline was real."

    incorrect_guess = guesses(:incorrect_real_guess)
    assert_includes incorrect_guess.result_text, "Wrong! This headline was actually"
  end

  test "result_class should return appropriate CSS class" do
    correct_guess = guesses(:correct_real_guess)
    assert_equal "text-green-600", correct_guess.result_class

    incorrect_guess = guesses(:incorrect_real_guess)
    assert_equal "text-red-600", incorrect_guess.result_class
  end
end
