require 'test_helper'

class DeckControllerTest < ActionController::TestCase
  test "list of decks" do
    get "index"
    assert_response 200
    assert_equal "Preconstructed Decks - mtg.wtf", html_document.title
  end

  test "all decks show correctly" do
    $CardDatabase.sets.each do |set_code, set|
      set.decks.each do |deck|
        get "show", params: {set: set_code, id: deck.slug}
        assert_response 200
        assert_select %Q[h4:contains("#{deck.name}")]
        assert_equal "#{deck.name} - #{set.name} #{deck.type} - mtg.wtf", html_document.title
      end
    end
  end

  test "fake set" do
    get "show", params: {set: "m99", id: "Homarids"}
    assert_response 404
  end

  test "fake deck for correct set" do
    get "show", params: {set: "m11", id: "Homarids"}
    assert_response 404
  end
end
