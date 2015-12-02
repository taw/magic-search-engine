require 'test_helper'

class SetControllerTest < ActionController::TestCase
  test "list of sets" do
    get "index"
    assert_response 200
    assert_select %Q[a:contains("Magic 2010")]
    assert_equal "mtg.wtf - Sets", html_document.title
  end

  test "actual set" do
    get "show", id: "nph"
    assert_response 200
    assert_select %Q[h3:contains("New Phyrexia")]
    assert_select %Q[a:contains("Karn Liberated")]
    assert_equal "mtg.wtf - New Phyrexia", html_document.title
  end

  test "fake set" do
    get "show", id: "lolwtf"
    assert_response 404
  end
end
