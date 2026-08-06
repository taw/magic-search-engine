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

  describe "download" do
    let(:set) { $CardDatabase.sets.values.find{|s| s.decks.present?} }
    let(:deck) { set.decks.first }

    it "download" do
      get "download", params: {set: set.code, id: deck.slug}
      assert_response 200
      expect(response.body).to eq(deck.to_text)
      expect(response.headers["Content-Disposition"]).to include(deck.name)
    end

    it "download_with_printings" do
      get "download_with_printings", params: {set: set.code, id: deck.slug}
      assert_response 200
      expect(response.body).to eq(deck.to_text_with_printings)
      expect(response.headers["Content-Disposition"]).to include(deck.name)
    end

    it "download - fake set" do
      get "download", params: {set: "m99", id: deck.slug}
      assert_response 404
    end

    it "download - fake deck" do
      get "download", params: {set: set.code, id: "lolwtf"}
      assert_response 404
    end

    it "download_with_printings - fake set" do
      get "download_with_printings", params: {set: "m99", id: deck.slug}
      assert_response 404
    end

    it "download_with_printings - fake deck" do
      get "download_with_printings", params: {set: set.code, id: "lolwtf"}
      assert_response 404
    end
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

    it "shows every section of a deck we exported" do
      deck = <<~EOF
        COMMANDER: 1 Ghave, Guru of Spores
        40 Lightning Bolt

        Sideboard
        1 Goblin Guide

        Planar Deck
        1 Naya

        Scheme Deck
        1 All in Good Time

        Display Commander
        1 Teneb, the Harvester
      EOF
      post "visualize", params: {deck: deck}
      assert_response 200
      assert_equal deck_list, [
        "1 Ghave, Guru of Spores {2}{W}{B}{G}",
        "40 Lightning Bolt {R}",
        "1 Goblin Guide {R}",
        "1 Naya",
        "1 All in Good Time",
        "1 Teneb, the Harvester {3}{W}{B}{G}",
      ]
    end

    it "deals with unknown cards" do
      post "visualize", params: {deck: "40x Lightning Bolt\n20x Pod of Greed"}
      assert_response 200
      assert_equal "Deck Visualizer - #{APP_NAME}", html_document.title
      assert_equal deck_list, ["40 Lightning Bolt {R}", "20 Pod of Greed"]
    end
  end
end
