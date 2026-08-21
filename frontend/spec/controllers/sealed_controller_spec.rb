require "rails_helper"

RSpec.describe SealedController, type: :controller do
  render_views

  it "index" do
    get "index"
    assert_response 200
    assert_equal "Sealed - #{APP_NAME}", html_document.title
  end

  it "open some packs" do
    get "index", params: {count: ["1", "2"], set: ["nph-draft", "arn"]}
    assert_response 200
    assert_equal "Sealed - #{APP_NAME}", html_document.title
    assert_select ".card_picture_container", count: 15 + 2 * 8
  end

  # A pool is a decklist too, and exporting it here saves the trip through the
  # visualizer. The dialog posts the same hidden field the preview form does.
  it "offers the export dialog for a pool" do
    get "index", params: {count: ["1"], set: ["arn"]}
    assert_response 200
    assert_select %[#deck_export input[name="format"]], DeckExporter.codes.size
    assert_select %[button[data-target="#deck_export"]]
    assert_select %[.sealed_preview_form input[name="deck"]]
  end

  it "has no export dialog before any packs are opened" do
    get "index"
    assert_response 200
    assert_select %[#deck_export], 0
  end

  # A pack the player got at random out of a few, like the allied guild booster
  # of the Dragon's Maze prerelease
  it "open a pack picked at random out of a few" do
    sizes = 20.times.map do
      get "index", params: {count: ["1"], set: ["nph-draft|arn"]}
      assert_response 200
      css_select(".card_picture_container").size
    end
    assert_equal [8, 15], sizes.uniq.sort
  end

  it "open a Dragon's Maze prerelease pool" do
    get "index", params: {
      count: ["4", "1", "1"],
      set: [
        "dgm-draft",
        "rtr-prerelease-azorius",
        "gtc-prerelease-orzhov|gtc-prerelease-dimir|gtc-prerelease-boros|gtc-prerelease-simic",
      ],
    }
    assert_response 200
    assert_select ".card_picture_container", count: 6 * 15
    # A random pack is not a booster type, so the dropdowns get an extra option
    # for it, or the row would have nothing selected
    random = "gtc-prerelease-orzhov|gtc-prerelease-dimir|gtc-prerelease-boros|gtc-prerelease-simic"
    assert_select %[select#set_2 option[selected][value=?]], random
    assert_select %[select#set_0 option[value=?]], random
    assert_select %[option:contains("Random: Gatecrash Prerelease Pack Orzhov, ")]
  end

  it "no random option without a random pack" do
    get "index"
    assert_response 200
    assert_select %[option:contains("Random: ")], false
  end

  # The pack codes come straight out of the url
  it "ignores packs it doesn't have" do
    get "index", params: {count: ["1", "1", "1"], set: ["lolwtf", "nph-lolwtf", "arn"]}
    assert_response 200
    assert_select ".card_picture_container", count: 8
  end

  it "ignores a random pack whose alternatives it doesn't have" do
    get "index", params: {count: ["1"], set: ["lolwtf|nolwtf"]}
    assert_response 200
    assert_select ".card_picture_container", 0
  end

  describe "fixed cards" do
    it "hands out the fixed cards along with the packs" do
      get "index", params: {count: ["1"], set: ["arn"], fixed: "2x nph:1\nnph:2:foil"}
      assert_response 200
      assert_select ".card_picture_container", count: 8 + 3
      assert_select %[a[href="/card/nph/1/Karn-Liberated"]], 2
      assert_select ".warning", 0
    end

    # The box is hand-edited, so a bad line must not cost the player their pool
    it "reports lines it can't parse, and opens the packs anyway" do
      get "index", params: {count: ["1"], set: ["arn"], fixed: "whatever\nnph:1"}
      assert_response 200
      assert_select ".card_picture_container", count: 8 + 1
      assert_select %[.warning:contains("Invalid line: whatever")]
    end

    it "reports cards it can't find" do
      get "index", params: {count: ["1"], set: ["arn"], fixed: "lolwtf:1\nnph:9999"}
      assert_response 200
      assert_select %[.warning:contains("Cannot find set with code: lolwtf")]
      assert_select %[.warning:contains("Cannot find card set with number 9999 in set nph")]
    end

    # Whatever the player typed stays in the box, so they can fix it and retry
    it "keeps the box filled in" do
      get "index", params: {count: ["1"], set: ["arn"], fixed: "nph:1"}
      assert_response 200
      assert_select %[textarea#fixed], text: "nph:1"
    end

    # No packs means nothing was opened yet, just the form being shown
    it "does not hand out fixed cards on their own" do
      get "index", params: {fixed: "nph:1"}
      assert_response 200
      assert_select ".card_picture_container", 0
    end
  end
end
