require "test_helper"

class SealedControllerTest < ActionController::TestCase
  test "index" do
    get "index"
    assert_response 200
    assert_equal "Sealed - mtg.wtf", html_document.title
  end

  test "open some packs" do
    get "index", params: {count: ["1", "2"], set: ["nph", "an"]}
    assert_response 200
    assert_equal "Sealed - mtg.wtf", html_document.title
    assert_select ".card_picture_container", count: 15 + 2*8
  end
end
