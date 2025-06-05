require "test_helper"

class RoundTest < ActiveSupport::TestCase
  test "should belong to game and headline" do
    round = rounds(:correct_real_guess)
    assert_respond_to round, :game
    assert_respond_to round, :headline
    assert_instance_of Game, round.game
    assert_instance_of Headline, round.headline
  end

  test "should validate user_guess presence and inclusion" do
    round = Round.new(game: games(:new_game), headline: headlines(:real_headline))

    # Should require user_guess
    assert_not round.valid?
    assert_includes round.errors[:user_guess], "can't be blank"

    # Should only allow 'real' or 'fake'
    round.user_guess = "invalid"
    assert_not round.valid?
    assert_includes round.errors[:user_guess], "is not included in the list"

    # Should be valid with correct values
    round.user_guess = "real"
    assert round.valid?
  end

  test "should calculate correctness before save" do
    game = games(:new_game)
    real_headline = headlines(:real_headline)
    fake_headline = headlines(:fake_headline)

    # Correct guess for real headline
    correct_real = Round.new(game: game, headline: real_headline, user_guess: "real")
    correct_real.save!
    assert correct_real.correct?

    # Incorrect guess for real headline
    incorrect_real = Round.new(game: game, headline: real_headline, user_guess: "fake")
    incorrect_real.save!
    assert_not incorrect_real.correct?

    # Correct guess for fake headline
    correct_fake = Round.new(game: game, headline: fake_headline, user_guess: "fake")
    correct_fake.save!
    assert correct_fake.correct?

    # Incorrect guess for fake headline
    incorrect_fake = Round.new(game: game, headline: fake_headline, user_guess: "real")
    incorrect_fake.save!
    assert_not incorrect_fake.correct?
  end

  test "guess_text should capitalize user_guess" do
    round = rounds(:correct_real_guess)
    assert_equal "Real", round.guess_text
  end

  test "result_text should return appropriate message" do
    correct_round = rounds(:correct_real_guess)
    assert_includes correct_round.result_text, "Correct! This headline was real."

    incorrect_round = rounds(:incorrect_real_guess)
    assert_includes incorrect_round.result_text, "Wrong! This headline was actually real."
  end

  test "result_class should return appropriate CSS class" do
    correct_round = rounds(:correct_real_guess)
    assert_equal "text-green-600", correct_round.result_class

    incorrect_round = rounds(:incorrect_real_guess)
    assert_equal "text-red-600", incorrect_round.result_class
  end

  test "scopes should work correctly" do
    game = games(:active_game)
    total_rounds = game.rounds.count
    correct_count = game.rounds.correct.count
    incorrect_count = game.rounds.incorrect.count

    assert_equal total_rounds, correct_count + incorrect_count
    assert correct_count > 0  # Based on our fixtures
    assert incorrect_count > 0  # Based on our fixtures
  end
end
