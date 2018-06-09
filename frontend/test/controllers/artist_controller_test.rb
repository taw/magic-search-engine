require "test_helper"

class ArtistControllerTest < ActionController::TestCase
  test "list of artists" do
    get "index"
    assert_response 200
    assert_select %Q[a:contains("Yang Hong")]
    assert_select %Q[li:contains("Yang Hong\n(8 cards)")]
    assert_equal "Artists - #{APP_NAME}", html_document.title
  end

  test "actual artist" do
    get "show", params: {id: "steve_ellis"}
    assert_response 200
  end

  test "fake artist" do
    get "show", params: {id: "katy_perry"}
    assert_response 404
  end
end
