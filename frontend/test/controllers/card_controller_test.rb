require 'test_helper'

class CardControllerTest < ActionController::TestCase
  # show
  test "show card" do
    get "show", set: "nph", id: "1"
    assert_response 200
    assert_select %Q[.cardinfo:contains("Karn Liberated")]
    assert_equal "Karn Liberated - mtg.wtf", html_document.title
  end

  test "bad set" do
    get "show", set: "lolwtf", id: "1"
    assert_response 404
  end

  test "bad collector number" do
    get "show", set: "nph", id: "1000"
    assert_response 404
  end

  # search
    test "search nothing" do
    get "index"
    assert_response 200
    assert_select ".cardinfo", 0
    assert_select ".results_summary", 0
    assert_equal "mtg.wtf", html_document.title
  end

  test "search all" do
    get "index", q: "sort:new"
    assert_response 200
    assert_select ".cardinfo", 25
    assert_equal "sort:new - mtg.wtf", html_document.title
  end

  test "nothing found" do
    get "index", q: "optimus prime"
    assert_response 200
    assert_select ".cardinfo", 0
    assert_select %Q[.results_summary:contains("No cards found")]
    assert_equal "optimus prime - mtg.wtf", html_document.title
  end

  test "search something" do
    get "index", q: "Karn Liberated"
    assert_response 200
    assert_select %Q[.cardinfo:contains("Karn Liberated")]
    assert_select %Q[.results_summary:contains("1 card found")]
    assert_equal "Karn Liberated - mtg.wtf", html_document.title
  end
end
