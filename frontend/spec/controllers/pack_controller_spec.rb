require "rails_helper"

RSpec.describe PackController, type: :controller do
  render_views

  it "list of packs" do
    get "index"
    assert_response 200
    assert_select %[a:contains("Magic 2015")]
    assert_select %[li:contains("Kaladesh Remastered Arena Booster\n(KLR-ARENA)")]
    assert_equal "Packs - #{APP_NAME}", html_document.title
  end

  it "actual pack" do
    get "show", params: {id: "m14"}
    assert_response 200
    # assert_select %[.results_summary:contains("New Phyrexia contains 175 cards.")]
    # assert_select %[.results_summary:contains("It is part of Scars of Mirrodin block.")]
    # assert_select %[h3:contains("New Phyrexia")]
    # assert_select %[a:contains("Karn Liberated")]
    # assert_equal "New Phyrexia - #{APP_NAME}", html_document.title
  end

  it "shows what a pack is made of" do
    get "show", params: {id: "nph-draft"}
    assert_response 200
    assert_select %[li:contains("1x Sheet rare_mythic")]
    assert_select %[li:contains("3x Sheet uncommon")]
    assert_select %[li:contains("10x Sheet common")]
    assert_select %[li:contains("1x Sheet foil")]
    assert_select %[h3:contains("Sheets")]
    assert_select %[h4:contains("Sheet common (color balanced)")]
    assert_select %[a[href="/card/nph/1/Karn-Liberated"]]
    assert_select %[a[href*="/sealed?"]:contains("Explore this pack in Sealed.")]
  end

  # Packs where the rare slot is sometimes a mythic are rolled in two steps
  it "shows the variants of a pack that has them" do
    get "show", params: {id: "nph-draft"}
    assert_response 200
    assert_select %[*:contains("New Phyrexia Draft Booster has variants")]
  end

  # A pack asked for by set code alone still resolves to that set's booster
  it "finds a pack by set code" do
    get "show", params: {id: "nph"}
    assert_response 200
  end

  it "set without packs" do
    get "show", params: {id: "c15"}
    assert_response 404
  end

  it "fake pack" do
    get "show", params: {id: "lolwtf"}
    assert_response 404
  end
end
