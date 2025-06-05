require "test_helper"

class RoundsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @game = games(:new_game)
  end

  test "should get new round" do
    get new_game_round_url(@game)
    assert_response :success
    assert_select "h1", /Headline \d+/
    assert_select "button", /REAL/
    assert_select "button", /FAKE/
  end

  test "should create round with correct guess" do
    headline = headlines(:real_headline)

    assert_difference "@game.rounds.count", 1 do
      post game_rounds_url(@game), params: {
        round: { headline_id: headline.id },
        user_guess: "real"
      }
    end

    round = @game.rounds.last
    assert round.correct?
    assert_equal "real", round.user_guess
    assert_redirected_to game_round_path(@game, round)
  end

  test "should create round with incorrect guess" do
    headline = headlines(:real_headline)

    assert_difference "@game.rounds.count", 1 do
      post game_rounds_url(@game), params: {
        round: { headline_id: headline.id },
        user_guess: "fake"
      }
    end

    round = @game.rounds.last
    assert_not round.correct?
    assert_equal "fake", round.user_guess
  end

  test "should increment game score on correct guess" do
    headline = headlines(:real_headline)
    original_score = @game.score

    post game_rounds_url(@game), params: {
      round: { headline_id: headline.id },
      user_guess: "real"
    }

    assert_equal original_score + 1, @game.reload.score
  end

  test "should not increment game score on incorrect guess" do
    headline = headlines(:real_headline)
    original_score = @game.score

    post game_rounds_url(@game), params: {
      round: { headline_id: headline.id },
      user_guess: "fake"
    }

    assert_equal original_score, @game.reload.score
  end

  test "should show round results" do
    round = rounds(:correct_real_guess)

    get game_round_url(round.game, round)
    assert_response :success
    assert_select "h2", /Correct!/
  end

  test "should respond with turbo stream" do
    headline = headlines(:real_headline)

    post game_rounds_url(@game),
         params: {
           round: { headline_id: headline.id },
           user_guess: "real"
         },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end
end
