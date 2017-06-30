require 'test_helper'

class CardControllerTest < ActionController::TestCase
  # show
  test "show card" do
    get "show", params: {set: "nph", id: "1"}
    assert_response 200
    assert_select %Q[.cardinfo:contains("Karn Liberated")]
    assert_equal "Karn Liberated - Lore Seeker", html_document.title
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
    assert_equal "Island - Lore Seeker", html_document.title
  end

  # search
  test "search nothing" do
    get "index"
    assert_response 200
    assert_select ".cardinfo", 0
    assert_select ".results_summary", 0
    assert_equal "Lore Seeker", html_document.title
  end

  test "search all" do
    get "index", params: {q: "sort:new"}
    assert_response 200
    assert_select ".cardinfo", 25
    assert_equal "sort:new - Lore Seeker", html_document.title
  end

  test "nothing found" do
    get "index", params: {q: "optimus prime"}
    assert_response 200
    assert_select ".cardinfo", 0
    assert_select %Q[.results_summary:contains("No cards found")]
    assert_equal "optimus prime - Lore Seeker", html_document.title
  end

  test "search something" do
    get "index", params: {q: "Karn Liberated"}
    assert_response 200
    assert_select %Q[.cardinfo:contains("Karn Liberated")]
    assert_select %Q[.results_summary:contains("1 card found")]
    assert_equal "Karn Liberated - Lore Seeker", html_document.title
  end

  # color indicator
  test "devoid" do
    get "index", params: {q: "Complete Disregard"}
    assert_equal "Devoid Exile target creature with power 3 or less.",
      html_document.at(".oracle").text.strip
  end

  test "color indicator" do
    get "index", params: {q: "Ancestral Vision"}
    assert_includes html_document.at(".oracle").text.strip, "(Color indicator: Ancestral Vision is blue)"
  end

  test "DFCs" do
    get "index", params: {q: "Garruk, the Veil-Cursed"}
    assert_includes html_document.at(".oracle").text.strip, "(Color indicator: Garruk, the Veil-Cursed is black and green)"
  end

  test "Transguild Courier" do
    get "index", params: {q: "Transguild Courier"}
    assert_includes html_document.at(".oracle").text.strip, "(Color indicator: Transguild Courier is all colors)"
  end

  test "Ghostfire" do
    get "index", params: {q: "Ghostfire"}
    assert_equal "Ghostfire is colorless.Ghostfire deals 3 damage to target creature or player.",
      html_document.at(".oracle").text.strip
  end
end
