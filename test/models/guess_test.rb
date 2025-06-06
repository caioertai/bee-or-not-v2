require "test_helper"

class GuessTest < ActiveSupport::TestCase
  test "should belong to round" do
    guess = guesses(:correct_real_guess)
    assert_respond_to guess, :round
    assert_instance_of Round, guess.round
  end

  test "should validate real field presence and inclusion" do
    round = rounds(:current_round)
    guess = Guess.new(round: round)

    # Should require real field
    assert_not guess.valid?
    assert_includes guess.errors[:real], "is not included in the list"

    # Should be valid with boolean values
    guess.real = true
    assert guess.valid?
    
    guess.real = false
    assert guess.valid?
  end

  test "correct? should return true when guess matches headline reality" do
    round = rounds(:current_round)
    real_headline = round.headline  # This is real_headline from fixtures

    # Correct guess for real headline
    correct_guess = Guess.new(round: round, real: true)
    assert correct_guess.correct?

    # Incorrect guess for real headline
    incorrect_guess = Guess.new(round: round, real: false)
    assert_not incorrect_guess.correct?
  end

  test "guess_text should return proper text for boolean real value" do
    real_guess = guesses(:correct_real_guess)
    assert_equal "Real", real_guess.guess_text
    
    fake_guess = guesses(:correct_fake_guess)
    assert_equal "Fake", fake_guess.guess_text
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
