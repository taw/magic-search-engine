require 'test_helper'

class ArtistControllerTest < ActionController::TestCase
  test "list of artists" do
    get "index"
    assert_response 200
    assert_select %Q[a:contains("Yang Hong")]
    assert_select %Q[li:contains("Yang Hong\n(8 cards)")]
    assert_equal "Artists - mtg.wtf", html_document.title
  end

  test "actual artist" do
    get "show", id: "steve_ellis"
    assert_response 200
  end

  test "fake artist" do
    get "show", id: "katy_perry"
    assert_response 404
  end
end
