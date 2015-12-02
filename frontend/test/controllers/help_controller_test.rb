require 'test_helper'

class HelpControllerTest < ActionController::TestCase
  test "smoke test" do
    get "syntax"
    assert_response 200
    assert_select %Q[h3:contains("Search Help")]
    assert_equal "mtg.wtf - Syntax", html_document.title
  end

  test "comprehensive rules" do
    get "rules"
    assert_response 200
    assert_select %Q[*:contains("Magic: The Gathering Comprehensive Rules")]
    assert_equal "mtg.wtf - Magic: The Gathering Comprehensive Rules", html_document.title
  end

  test "contact" do
    get "contact"
    assert_response 200
    assert_select %Q[div:contains("You can contact me by")]
    assert_equal "mtg.wtf - Contact", html_document.title
  end
end
