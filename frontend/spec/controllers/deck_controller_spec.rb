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
        assert_select %[h4:contains("#{deck.name}")]
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

  describe "visualizer" do
    let(:deck_list) { html_document.css(".card_entry").map(&:text).map { |x| x.split(/\s+/).join(" ").strip } }

    it "shows visualizer" do
      get "visualize"
      assert_response 200
      assert_equal "Deck Visualizer - #{APP_NAME}", html_document.title
      assert_equal deck_list, []
    end

    it "shows deck if you put it in textarea" do
      post "visualize", params: {deck: "40x Lightning Bolt\n20x Mountain"}
      assert_response 200
      assert_equal "Deck Visualizer - #{APP_NAME}", html_document.title
      assert_equal deck_list, ["40 Lightning Bolt {R}", "20 Mountain"]
    end

    it "shows deck if you upload it" do
      path = "#{__dir__}/decks/normal.txt"
      post "visualize", params: {deck_upload: Rack::Test::UploadedFile.new(path)}
      assert_response 200
      assert_equal "Deck Visualizer - #{APP_NAME}", html_document.title
      assert_equal deck_list, ["20 Dandân {U}{U}", "30 Lightning Bolt {R}", "10 Mountain"]
    end

    it "ignores UTF-8 BOM" do
      path = "#{__dir__}/decks/utf8_bom.txt"
      post "visualize", params: {deck_upload: Rack::Test::UploadedFile.new(path)}
      assert_response 200
      assert_equal "Deck Visualizer - #{APP_NAME}", html_document.title
      assert_equal deck_list, ["20 Dandân {U}{U}", "30 Lightning Bolt {R}", "10 Mountain"]
    end

    it "deals with Windows encoding and line endings" do
      path = "#{__dir__}/decks/windows.txt"
      post "visualize", params: {deck_upload: Rack::Test::UploadedFile.new(path)}
      assert_response 200
      assert_equal "Deck Visualizer - #{APP_NAME}", html_document.title
      assert_equal deck_list, ["20 Dandân {U}{U}", "30 Lightning Bolt {R}", "10 Mountain"]
    end

    it "deals with Mac line endings" do
      path = "#{__dir__}/decks/mac.txt"
      post "visualize", params: {deck_upload: Rack::Test::UploadedFile.new(path)}
      assert_response 200
      assert_equal "Deck Visualizer - #{APP_NAME}", html_document.title
      assert_equal deck_list, ["20 Dandân {U}{U}", "30 Lightning Bolt {R}", "10 Mountain"]
    end

    it "deals with unknown cards" do
      post "visualize", params: {deck: "40x Lightning Bolt\n20x Pod of Greed"}
      assert_response 200
      assert_equal "Deck Visualizer - #{APP_NAME}", html_document.title
      assert_equal deck_list, ["40 Lightning Bolt {R}", "20 Pod of Greed"]
    end
  end
end
