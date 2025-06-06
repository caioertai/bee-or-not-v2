require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_game_url
    assert_response :success
    assert_select "h1", "🐝 Ready to Play?"
  end

  test "should create game and redirect to first guess" do
    assert_difference "Game.count", 1 do
      post games_url
    end

    game = Game.last
    assert_response :redirect
    assert_redirected_to new_game_guess_path(game)
  end

  test "should show game stats" do
    game = games(:completed_game)

    get game_url(game)
    assert_response :success
    assert_select "h1", "Game Complete!"
    assert_select ".bg-blue-50"  # Score display area exists
  end

  test "should return 404 for invalid game" do
    get game_url(999999)
    assert_response :not_found
  end

  # Multiplayer tests
  test "should create game and add current player" do
    assert_difference [ "Game.count", "Player.count", "GamePlayer.count" ], 1 do
      post games_url
    end

    game = Game.last
    assert_equal 1, game.players.count
    assert_response :redirect
    assert_redirected_to new_game_guess_path(game)
  end
end
