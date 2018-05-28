require "test_helper"

class SealedControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get "index"
    assert_response 200
    assert_equal "Sealed - mtg.wtf", html_document.title
  end
end
