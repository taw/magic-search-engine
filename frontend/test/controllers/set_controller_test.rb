require 'test_helper'

class SetControllerTest < ActionController::TestCase
  test "list of sets" do
    get "index"
    assert_response 200
    assert_select %Q[a:contains("Magic 2015 Core Set")]
    assert_select %Q[li:contains("Magic 2015 Core Set\n(M15, 284 cards)")]
    assert_equal "Sets - Lore Seeker", html_document.title
  end

  test "actual set" do
    get "show", id: "nph"
    assert_response 200
    assert_select %Q[.results_summary:contains("New Phyrexia contains 175 cards.")]
    assert_select %Q[.results_summary:contains("It is part of Scars of Mirrodin block.")]
    assert_select %Q[h3:contains("New Phyrexia")]
    assert_select %Q[a:contains("Karn Liberated")]
    assert_equal "New Phyrexia - Lore Seeker", html_document.title
  end

  test "fake set" do
    get "show", id: "lolwtf"
    assert_response 404
  end
end
