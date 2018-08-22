require "test_helper"

class CardControllerTest < ActionController::TestCase
  # show
  test "show card" do
    get "show", params: {set: "nph", id: "1"}
    assert_response 200
    assert_select %Q[.cardinfo:contains("Karn Liberated")]
    assert_equal "Karn Liberated - #{APP_NAME}", html_document.title
  end

  test "bad set" do
    get "show", params: {set: "lolwtf", id: "1"}
    assert_response 404
  end

  test "bad collector number" do
    get "show", params: {set: "nph", id: "1000"}
    assert_response 404
  end

  # gallery
  test "show card gallery - bad set" do
    get "gallery", params: {set: "lolwtf", id: "1"}
    assert_response 404
  end

  test "show card gallery - bad collector number" do
    get "gallery", params: {set: "nph", id: "1000"}
    assert_response 404
  end

  test "show card gallery - not first printing" do
    get "gallery", params: {set: "nph", id: "168"}
    assert_response 302
    assert_redirected_to action: "gallery", set: "al", id: "281"
  end

  test "show card gallery - not first card in first printing" do
    get "gallery", params: {set: "al", id: "282"}
    assert_response 302
    assert_redirected_to action: "gallery", set: "al", id: "281"
  end

  test "show card gallery - first card in first printing" do
    get "gallery", params: {set: "al", id: "281"}
    assert_response 200
    assert_equal "Island - #{APP_NAME}", html_document.title
  end

  # search
  test "search nothing" do
    get "index"
    assert_response 200
    assert_select ".cardinfo", 0
    assert_select ".results_summary", 0
    assert_equal "#{APP_NAME}", html_document.title
  end

  test "search all" do
    get "index", params: {q: "sort:new"}
    assert_response 200
    assert_select ".cardinfo", 25
    assert_equal "sort:new - #{APP_NAME}", html_document.title
  end

  test "nothing found" do
    get "index", params: {q: "optimus prime"}
    assert_response 200
    assert_select ".cardinfo", 0
    assert_select %Q[.results_summary:contains("No cards found")]
    assert_equal "optimus prime - #{APP_NAME}", html_document.title
  end

  test "search something" do
    get "index", params: {q: "Karn Liberated"}
    assert_response 200
    assert_select %Q[.cardinfo:contains("Karn Liberated")]
    assert_select %Q[.results_summary:contains("1 card found")]
    assert_equal "Karn Liberated - #{APP_NAME}", html_document.title
  end

  test "view:default" do
    get "index", params: {q: "t:planeswalker"}
    assert_response 200
    assert_select ".card_picture_container", 25
    assert_select ".card_title", 25
  end

  test "view:images" do
    get "index", params: {q: "t:planeswalker view:images"}
    assert_response 200
    assert_select ".card_picture_container", 60
    assert_select ".card_title", 0
  end

  test "view:text" do
    get "index", params: {q: "t:planeswalker view:text"}
    assert_response 200
    assert_select ".card_picture_container", 0
    assert_select ".card_title", 60
  end

  # color indicator
  test "devoid" do
    get "index", params: {q: "Complete Disregard"}
    text = html_document.at(".oracle").inner_html.strip.gsub("<br>", "\n")
    assert_equal "Devoid\nExile target creature with power 3 or less.", text
  end

  test "color indicator" do
    get "index", params: {q: "Ancestral Vision"}
    text = html_document.at(".oracle").inner_html.strip.gsub("<br>", "\n")
    assert_includes text, "(Color indicator: Ancestral Vision is blue)"
  end

  test "DFCs" do
    get "index", params: {q: "Garruk, the Veil-Cursed"}
    text = html_document.at(".oracle").inner_html.strip.gsub("<br>", "\n")
    assert_includes text, "(Color indicator: Garruk, the Veil-Cursed is black and green)"
  end

  test "Transguild Courier" do
    get "index", params: {q: "Transguild Courier"}
    text = html_document.at(".oracle").inner_html.strip.gsub("<br>", "\n")
    assert_includes text, "(Color indicator: Transguild Courier is all colors)"
  end

  test "Ghostfire" do
    get "index", params: {q: "Ghostfire"}
    text = html_document.at(".oracle").inner_html.strip.gsub("<br>", "\n")
    assert_equal "Ghostfire is colorless.\nGhostfire deals 3 damage to any target.", text
  end
end
