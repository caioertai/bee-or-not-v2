require "test_helper"

class GameTest < ActiveSupport::TestCase
  test "should be valid" do
    game = Game.new
    assert game.valid?
  end

  test "score should return count of correct guesses" do
    game = games(:active_game)
    expected_score = game.guesses.joins(round: :headline)
                         .where("guesses.real = headlines.real")
                         .count
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

  test "total_rounds should return count of completed rounds" do
    game = games(:active_game)
    # Total rounds should count rounds that have guesses
    expected_total = game.rounds.joins(:guesses).distinct.count
    assert_equal expected_total, game.total_rounds
  end

  test "correct_rounds should return count of correct rounds" do
    game = games(:active_game)
    expected_correct = game.rounds.joins(guesses: { round: :headline })
                           .where("guesses.real = headlines.real")
                           .distinct.count
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

  test "create_next_round! should not use headlines already used in the game" do
    game = Game.create!
    game.rounds.destroy_all

    # Create rounds for all but one headline
    all_headlines = Headline.all
    used_headlines = all_headlines.first(all_headlines.count - 1)

    used_headlines.each do |headline|
      round = game.rounds.create!(headline: headline)
      round.guesses.create!(real: true)  # Complete the round
    end

    # Create next round should use the remaining headline
    remaining_headline = all_headlines.last
    new_round = game.create_next_round!

    assert_equal remaining_headline, new_round.headline
    assert_not_includes used_headlines, new_round.headline
  end

  test "create_next_round! should return nil when no headlines are available" do
    game = Game.create!
    game.rounds.destroy_all

    # Create rounds for all headlines
    Headline.all.each do |headline|
      round = game.rounds.create!(headline: headline)
      round.guesses.create!(real: true)  # Complete the round
    end

    # Should return nil when no headlines are left
    assert_nil game.create_next_round!
  end

  test "completed? should return false when headlines are available" do
    game = Game.create!
    game.rounds.destroy_all

    # Create a round for only one headline
    headline = Headline.first
    round = game.rounds.create!(headline: headline)
    round.guesses.create!(real: true)

    assert_not game.completed?
  end

  test "completed? should return true when all headlines have been used" do
    game = Game.create!
    game.rounds.destroy_all

    # Use all headlines
    Headline.all.each do |headline|
      round = game.rounds.create!(headline: headline)
      round.guesses.create!(real: true)
    end

    assert game.completed?
  end

  test "available_headlines method should exclude headlines already used in rounds" do
    game = Game.create!
    game.rounds.destroy_all

    # Use first headline
    used_headline = Headline.first
    game.rounds.create!(headline: used_headline)

    available = game.available_headlines

    assert_not_includes available, used_headline
    assert_equal Headline.count - 1, available.count
  end

  test "should have available_headlines method" do
    game = Game.create!
    assert_respond_to game, :available_headlines
    assert_kind_of ActiveRecord::Relation, game.available_headlines
  end
end
