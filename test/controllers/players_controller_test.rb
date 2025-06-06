require "test_helper"

class PlayersControllerTest < ActionDispatch::IntegrationTest
  test "should show new player page" do
    game = games(:one)

    get new_game_player_url(game)
    assert_response :success
    assert_select "h1", "Join Game"
    assert_select "form[action='#{game_players_path(game)}']"
  end

  test "should create player and join game" do
    game = games(:one)
    initial_player_count = game.players.count

    post game_players_url(game), params: { player_name: "New Player" }

    assert_response :redirect
    assert_redirected_to new_game_guess_path(game)
    assert_equal initial_player_count + 1, game.reload.players.count
  end

  test "should update existing player name when joining" do
    game = games(:one)

    # Set up a player in cookies to simulate existing player
    cookies[:player_uuid] = players(:alice).uuid
    initial_player_count = game.players.count

    post game_players_url(game), params: { player_name: "Updated Alice" }

    assert_response :redirect
    assert_redirected_to new_game_guess_path(game)
    # Player count shouldn't increase if player already exists in game
    assert_equal initial_player_count, game.reload.players.count
    assert_equal "Updated Alice", players(:alice).reload.name
  end
end
