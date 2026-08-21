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

  # Commander 2011 is as settled as precon data gets
  describe "a commander deck" do
    before do
      get "show", params: {set: "cmd", id: "counterpunch"}
      assert_response 200
    end

    it "puts the commander first, then the cards by type" do
      groups = css_select(".card_group h6").map(&:text).map{|t| t.sub(/ \(\d+\)\z/, "")}
      assert_equal groups.first, "Commander"
      assert_equal groups.last, "Display Commander"
      assert_includes groups, "Creature"
      assert_includes groups, "Land"
      assert_equal groups, groups.uniq
    end

    it "counts the cards of each group" do
      assert_select %[.card_group h6:contains("Commander (1)")]
      counts = css_select(".card_group h6").map{|h| h.text[/\((\d+)\)/, 1].to_i}
      # 99 main deck cards, the commander, and the three oversized commanders
      assert_equal counts.sum, 103
    end

    # Hovering a card name swaps the big picture, so every card needs one,
    # and exactly one of them starts out visible
    it "previews the commander by default" do
      previews = css_select(".card_picture_cell")
      shown = previews.reject{|cell| cell["style"].to_s.include?("display: none")}
      assert_equal shown.map{|cell| cell["data-preview"]}, ["cmd-200"]
      ids = previews.map{|cell| cell["data-preview"]}
      assert_equal ids, ids.uniq
      # The oversized commanders are foil, and a different card from cmd-200
      assert_includes ids, "ocmd-200-foil"
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
      expect(response.body).to eq(deck.export("names").text)
      expect(response.headers["Content-Disposition"]).to include(deck.name)
    end

    it "download_with_printings" do
      get "download_with_printings", params: {set: set.code, id: deck.slug}
      assert_response 200
      expect(response.body).to eq(deck.export("text").text)
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

  describe "export" do
    let(:set) { $CardDatabase.sets["cmd"] }
    let(:deck) { set.decks.find{|d| d.slug == "counterpunch"} }
    let(:json) { JSON.parse(response.body) }

    it "returns one format of a precon deck" do
      get "export", params: {set: set.code, id: deck.slug, format: "arena"}
      assert_response 200
      expect(json["text"]).to eq(deck.export("arena").text)
      expect(json["filename"]).to eq("Counterpunch.txt")
      expect(json["warnings"]).to eq(deck.export("arena").warnings)
    end

    it "returns every format we offer" do
      DeckExporter.codes.each do |code|
        get "export", params: {set: set.code, id: deck.slug, format: code}
        assert_response 200
        body = JSON.parse(response.body)
        expect(body["text"]).to eq(deck.export(code).text)
        expect(body["filename"]).to end_with(".#{DeckExporter[code].extension}")
      end
    end

    it "returns the warnings the format collected" do
      get "export", params: {set: set.code, id: deck.slug, format: "xmage"}
      assert_response 200
      expect(json["warnings"]).to include(
        "Commander goes to the sideboard, as the format has no place to mark it"
      )
    end

    it "exports a decklist posted back from the visualizer" do
      post "export", params: {deck: "4x Lightning Bolt\n20x Mountain", format: "names"}
      assert_response 200
      expect(json["text"]).to eq("4 Lightning Bolt\n20 Mountain\n")
      # A pasted deck has no name of its own
      expect(json["filename"]).to eq("deck.txt")
    end

    it "keeps the printings a pasted decklist named" do
      post "export", params: {deck: "1 Sol Ring (C21) 263 *F*", format: "arena"}
      assert_response 200
      expect(json["text"]).to eq("Deck\n1 Sol Ring (C21) 263 *F*\n")
    end

    it "404s for a format we do not have" do
      get "export", params: {set: set.code, id: deck.slug, format: "mwdeck"}
      assert_response 404
      get "export", params: {set: set.code, id: deck.slug}
      assert_response 404
    end

    it "404s for a deck we do not have" do
      get "export", params: {set: "m99", id: deck.slug, format: "text"}
      assert_response 404
      get "export", params: {set: set.code, id: "lolwtf", format: "text"}
      assert_response 404
    end

    it "404s for an empty decklist" do
      post "export", params: {deck: "", format: "text"}
      assert_response 404
      post "export", params: {format: "text"}
      assert_response 404
    end
  end

  describe "the export dialog" do
    it "offers every format on a deck page, and says which the deck is" do
      get "show", params: {set: "cmd", id: "counterpunch"}
      assert_response 200
      assert_select %[#deck_export input[name="format"]], DeckExporter.codes.size
      # What the dialog posts back, so the endpoint knows which deck it is
      assert_select %[#deck_export_form input[name="set"][value="cmd"]]
      assert_select %[#deck_export_form input[name="id"][value="counterpunch"]]
      assert_select %[button[data-target="#deck_export"]]
    end

    # The visualizer's deck is the text in the paste box, which is what the
    # dialog sends instead of a url
    it "names no deck on the visualizer" do
      post "visualize", params: {deck: "40x Lightning Bolt"}
      assert_response 200
      assert_select %[#deck_export input[name="format"]], DeckExporter.codes.size
      assert_select %[#deck_export_form input[name="set"]], 0
      assert_select %[#deck_export_form input[name="id"]], 0
    end

    it "is not there when the visualizer has no deck" do
      get "visualize"
      assert_response 200
      assert_select %[#deck_export], 0
    end

    it "starts on the format the settings page saved" do
      request.cookies["default_deck_export"] = "mythichub"
      get "show", params: {set: "cmd", id: "counterpunch"}
      assert_select %[#deck_export input[name="format"][checked]], 1
      assert_select %[#deck_export input[name="format"][value="mythichub"][checked]]
    end

    it "falls back to our own format when the cookie is nonsense" do
      request.cookies["default_deck_export"] = "lolwtf"
      get "show", params: {set: "cmd", id: "counterpunch"}
      assert_select %[#deck_export input[name="format"][checked]], 1
      assert_select %[#deck_export input[name="format"][value="text"][checked]]
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

    it "shows an arena decklist you upload" do
      path = "#{__dir__}/decks/arena.txt"
      post "visualize", params: {deck_upload: Rack::Test::UploadedFile.new(path)}
      assert_response 200
      assert_equal deck_list, [
        "1 Lightning Bolt {R}",
        "4 Swords to Plowshares {W}",
        "2 Arid Mesa",
      ]
    end

    it "deals with unknown cards" do
      post "visualize", params: {deck: "40x Lightning Bolt\n20x Pod of Greed"}
      assert_response 200
      assert_equal "Deck Visualizer - #{APP_NAME}", html_document.title
      assert_equal deck_list, ["40 Lightning Bolt {R}", "20 Pod of Greed"]
    end

    # Cockatrice, XMage and friends export xml, not text
    it "shows a deck exported by another program" do
      path = "#{__dir__}/decks/cockatrice.cod"
      post "visualize", params: {deck_upload: Rack::Test::UploadedFile.new(path)}
      assert_response 200
      assert_equal deck_list, ["4 Lightning Bolt {R}", "20 Mountain", "2 Dandân {U}{U}"]
    end

    it "says so instead of blowing up on a file that isn't a deck at all" do
      path = "#{__dir__}/decks/binary.dat"
      post "visualize", params: {deck_upload: Rack::Test::UploadedFile.new(path)}
      assert_response 200
      assert_select %[.warning:contains("Can't parse uploaded deck.")]
      assert_equal deck_list, []
    end

    def visible_preview
      previews = css_select(".card_picture_cell")
      shown = previews.reject{|cell| cell["style"].to_s.include?("display: none")}
      shown.map{|cell| cell["data-preview"]}
    end

    it "previews the commander" do
      post "visualize", params: {deck: "COMMANDER: 1 Ghave, Guru of Spores\n40 Lightning Bolt"}
      assert_response 200
      commander = css_select(".previewable_card_name").first
      assert_includes commander.text, "Ghave, Guru of Spores"
      assert_equal visible_preview, [commander["data-preview-link"]]
    end

    # There is no picture to preview for a card we know nothing about, so the
    # preview box would have been blank
    it "previews something else if the commander is a card we don't know" do
      post "visualize", params: {deck: "COMMANDER: 1 Pod of Greed\n40 Lightning Bolt"}
      assert_response 200
      assert_equal visible_preview.size, 1
    end

    it "has nothing to preview if we know none of the cards" do
      post "visualize", params: {deck: "40x Pod of Greed"}
      assert_response 200
      assert_equal visible_preview, []
    end

    # Cards are grouped by type, in the order decklists are usually printed in
    it "groups cards by type" do
      deck = <<~EOF
        1 Karn Liberated
        1 Alpha Myr
        1 Ancient Den
        1 Aether Spellbomb
        1 Altar's Light
        1 Barter in Blood
        1 Arrest
        1 Adriana's Valor
      EOF
      post "visualize", params: {deck: deck}
      assert_response 200
      assert_equal css_select(".decklist h6").map(&:text), [
        "Creature (1)", "Planeswalker (1)", "Instant (1)", "Sorcery (1)",
        "Artifact (1)", "Enchantment (1)", "Land (1)", "Other (1)",
      ]
    end
  end
end
