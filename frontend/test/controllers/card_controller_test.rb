require 'test_helper'

class CardControllerTest < ActionController::TestCase
  # show
  test "show card" do
    get "show", set: "nph", id: "1"
    assert_response 200
    assert_select %Q[.card:contains("Karn Liberated")]
    assert_equal "mtg.wtf - Karn Liberated", html_document.title
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
    assert_select ".card", 0
    assert_select ".zero_results", 0
    assert_equal "mtg.wtf", html_document.title
  end

  test "search all" do
    get "index", q: "sort:new"
    assert_response 200
    assert_select ".card", 25
    assert_equal "mtg.wtf - sort:new", html_document.title
  end

  test "nothing found" do
    get "index", q: "optimus prime"
    assert_response 200
    assert_select ".card", 0
    assert_select ".zero_results"
    assert_equal "mtg.wtf - optimus prime", html_document.title
  end

  test "search something" do
    get "index", q: "Karn Liberated"
    assert_response 200
    assert_select %Q[.card:contains("Karn Liberated")]
    assert_equal "mtg.wtf - Karn Liberated", html_document.title
  end
end
