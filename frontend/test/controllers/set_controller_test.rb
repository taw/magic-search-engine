require 'test_helper'

class SetControllerTest < ActionController::TestCase
  test "list of sets" do
    get "index"
    assert_response 200
    assert_select %Q[a:contains("Magic 2010")]
    assert_equal "Sets - mtg.wtf", html_document.title
  end

  test "actual set" do
    get "show", id: "nph"
    assert_response 200
    assert_select %Q[.results_summary:contains("New Phyrexia contains 175 cards")]
    assert_select %Q[h3:contains("New Phyrexia")]
    assert_select %Q[a:contains("Karn Liberated")]
    assert_equal "New Phyrexia - mtg.wtf", html_document.title
  end

  test "fake set" do
    get "show", id: "lolwtf"
    assert_response 404
  end
end
