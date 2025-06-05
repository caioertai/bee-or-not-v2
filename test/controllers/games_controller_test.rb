require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_game_url
    assert_response :success
    assert_select "h1", "🐝 Ready to Play?"
  end

  test "should create game and redirect to current round" do
    post games_url
    assert_response :redirect

    game_id = session[:game_id]
    assert_not_nil game_id
    assert_equal 0, session[:score]
    assert_equal 0, session[:total_rounds]

    assert_redirected_to game_current_round_path(game_id)
  end

  test "should show game stats" do
    # Create a game session first
    post games_url
    game_id = session[:game_id]

    # Just verify the page loads correctly with a valid game_id session
    get game_url(game_id)
    assert_response :success
    assert_select "h1", "Game Complete!"  # Check for page title
    # Verify the game stats section exists
    assert_select ".bg-blue-50"  # Score display area exists
  end

  test "should redirect to new game if no session" do
    get game_url("any-id")
    assert_redirected_to new_game_path
  end
end
