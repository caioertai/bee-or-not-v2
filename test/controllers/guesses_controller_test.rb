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
    correct_answer = "real"  # We know this headline is real

    assert_difference "@game.rounds.joins(:guesses).distinct.count", 1 do
      post game_guess_url(@game), params: {
        guess: { user_guess: correct_answer }
      }
    end

    assert_response :redirect
    assert_equal 1, @game.reload.score
  end

  test "should create guess with incorrect answer" do
    # Create a round for the game first with a specific headline
    round = @game.rounds.create!(headline: headlines(:real_headline))
    incorrect_answer = "fake"  # This will be incorrect since headline is real

    assert_difference "Guess.count", 1 do
      post game_guess_url(@game), params: {
        guess: { user_guess: incorrect_answer }
      }
    end

    assert_equal 0, @game.reload.score
  end

  test "should respond with turbo stream" do
    post game_guess_url(@game),
         params: {
           guess: { user_guess: "real" }
         },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end
end
