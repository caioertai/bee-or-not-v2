require "test_helper"

class GuessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:new_game)
  end

  test "should get new guess" do
    get new_game_guess_url(@game)
    assert_response :success
    assert_select "h1", /Headline \d+/
    assert_select "button", /REAL/
    assert_select "button", /FAKE/
  end

  test "should create a new round if there is no current round" do
    @game.rounds.destroy_all
    get new_game_guess_url(@game)
    assert_response :success
    assert_select "h1", /Headline \d+/
    assert_select "button", /REAL/
    assert_select "button", /FAKE/
  end

  test "should create guess with correct answer" do
    # Create a round for the game first with a specific headline
    round = @game.rounds.create!(headline: headlines(:real_headline))
    correct_answer = true  # We know this headline is real

    assert_difference "@game.rounds.joins(:guesses).distinct.count", 1 do
      post game_guess_url(@game), params: {
        guess: { real: correct_answer }
      }
    end

    assert_response :redirect
    assert_equal 1, @game.reload.score
  end

  test "should create guess with incorrect answer" do
    # Create a round for the game first with a specific headline
    round = @game.rounds.create!(headline: headlines(:real_headline))
    incorrect_answer = false  # This will be incorrect since headline is real

    assert_difference "Guess.count", 1 do
      post game_guess_url(@game), params: {
        guess: { real: incorrect_answer }
      }
    end

    assert_equal 0, @game.reload.score
  end

  test "should respond with turbo stream" do
    post game_guess_url(@game),
         params: {
           guess: { real: true }
         },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end

  test "should redirect to game show when game is completed" do
    # Use all headlines except one
    all_headlines = Headline.all
    used_headlines = all_headlines.first(all_headlines.count - 1)

    @game.rounds.destroy_all
    used_headlines.each do |headline|
      round = @game.rounds.create!(headline: headline)
      round.guesses.create!(real: true)
    end

    # Make the final guess that completes the game
    last_headline = all_headlines.last
    @game.rounds.create!(headline: last_headline)

    post game_guess_url(@game), params: { guess: { real: true } }

    assert_redirected_to game_path(@game)
  end

  test "should redirect to game show when accessing new guess for completed game" do
    # Complete the game first
    @game.rounds.destroy_all
    Headline.all.each do |headline|
      round = @game.rounds.create!(headline: headline)
      round.guesses.create!(real: true)
    end

    get new_game_guess_url(@game)

    assert_redirected_to game_path(@game)
  end

  test "should show completion message in turbo stream when game is completed" do
    # Use all headlines except one
    all_headlines = Headline.all
    used_headlines = all_headlines.first(all_headlines.count - 1)

    @game.rounds.destroy_all
    used_headlines.each do |headline|
      round = @game.rounds.create!(headline: headline)
      round.guesses.create!(real: true)
    end

    # Make the final guess that completes the game
    last_headline = all_headlines.last
    @game.rounds.create!(headline: last_headline)

    post game_guess_url(@game),
         params: { guess: { real: true } },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_includes response.body, "No more headlines left!"
    assert_includes response.body, "Thanks for playing!"
  end
end
