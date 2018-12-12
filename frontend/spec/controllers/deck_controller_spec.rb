require "rails_helper"

RSpec.describe DeckController, type: :controller do
  render_views

  it "list of decks" do
    get "index"
    assert_response 200
    assert_equal "Preconstructed Decks - #{APP_NAME}", html_document.title
  end

  it "all decks show correctly" do
    $CardDatabase.sets.each do |set_code, set|
      set.decks.each do |deck|
        get "show", params: {set: set_code, id: deck.slug}
        assert_response 200
        assert_select %Q[h4:contains("#{deck.name}")]
        assert_equal "#{deck.name} - #{set.name} #{deck.type} - #{APP_NAME}", html_document.title
      end
    end
  end

  it "fake set" do
    get "show", params: {set: "m99", id: "Homarids"}
    assert_response 404
  end

  it "fake deck for correct set" do
    get "show", params: {set: "m11", id: "Homarids"}
    assert_response 404
  end
end
