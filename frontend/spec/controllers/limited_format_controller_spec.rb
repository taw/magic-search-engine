require "rails_helper"

RSpec.describe LimitedFormatController, type: :controller do
  render_views

  it "list of limited formats" do
    get "index"
    assert_response 200
    assert_equal "Limited Formats - #{APP_NAME}", html_document.title
    assert_select %[li:contains("New Phyrexia Draft")]
    assert_select %[li:contains("New Phyrexia Prerelease Sealed")]
    assert_select %[a[href="/limited_format/nph/draft"]:contains("New Phyrexia Draft")]
  end

  it "draft" do
    get "show", params: {set: "nph", id: "draft"}
    assert_response 200
    assert_equal "New Phyrexia Draft - #{APP_NAME}", html_document.title
    assert_select %[li a[href="/pack/nph-draft"]:contains("New Phyrexia Draft Booster")]
    assert_select %[li a[href="/pack/mbs-draft"]:contains("Mirrodin Besieged Draft Booster")]
    assert_select %[li a[href="/pack/som-draft"]:contains("Scars of Mirrodin Draft Booster")]
    assert_select %[p:contains("draft one card")]
    assert_select %[p:contains("build a 40 card deck")]
  end

  it "sealed" do
    get "show", params: {set: "nph", id: "prerelease-sealed"}
    assert_response 200
    assert_equal "New Phyrexia Prerelease Sealed - #{APP_NAME}", html_document.title
    assert_select %[li:contains("2x") a[href="/pack/nph-draft"]:contains("New Phyrexia Draft Booster")]
    assert_select %[li:contains("2x") a[href="/pack/som-draft"]:contains("Scars of Mirrodin Draft Booster")]
    assert_select %[p:contains("You also receive these promos")]
    assert_select %[a[href*="/card/pnph/73"]]
    assert_select %[a:contains("Open in Sealed simulator")] do |links|
      url = links.first["href"]
      assert_includes url, "count%5B%5D=2&count%5B%5D=2&count%5B%5D=2"
      assert_includes url, "set%5B%5D=nph-draft&set%5B%5D=mbs-draft&set%5B%5D=som-draft"
      assert_includes url, "fixed=1x+pnph%3A73%E2%98%85%3Afoil"
    end
  end

  it "sealed with a choice has one section per choice" do
    get "show", params: {set: "rtr", id: "prerelease-sealed"}
    assert_response 200
    assert_equal "Return to Ravnica Prerelease Sealed - #{APP_NAME}", html_document.title
    assert_select %[p:contains("You must choose one of the following guilds:")]
    assert_select %[ul li:contains("Azorius")]
    assert_select %[h4:contains("Selesnya")]
    assert_select "h4", 5
    # Each guild opens its own guild pack, and gets its own promo
    assert_select %[li:contains("1x") a[href="/pack/rtr-prerelease-azorius"]]
    assert_select %[p:contains("You also have access to these playable promos")], 5
    assert_select %[a:contains("Open in Sealed simulator")], 5 do |links|
      assert_includes links.first["href"], "set%5B%5D=rtr-draft&set%5B%5D=rtr-prerelease-azorius"
      assert_includes links.first["href"], "fixed=1x+prtr%3A142%E2%98%85%3Afoil"
    end
  end

  it "sealed with a choice pluralizes the choice" do
    get "show", params: {set: "ori", id: "prerelease-sealed"}
    assert_response 200
    assert_select %[p:contains("You must choose one of the following planeswalkers:")]
    assert_select %[h4:contains("Gideon")]
  end

  it "commander draft" do
    get "show", params: {set: "cmr", id: "draft"}
    assert_response 200
    assert_select %[p:contains("draft two cards")]
    assert_select %[p:contains("at least 60 cards")]
    assert_select %[p a:contains("The Prismatic Piper")]
    assert_select %[a[href="/help/rules#section-903-13"]]
    # Normal draft rules don't apply
    assert_select %[p:contains("draft one card")], false
    assert_select %[p:contains("40 card deck")], false
  end

  # Baldur's Gate ran its prerelease as a Commander Draft of the packs
  it "sealed format played as commander draft" do
    get "show", params: {set: "clb", id: "prerelease-sealed"}
    assert_response 200
    assert_select %[li:contains("3x") a[href="/pack/clb-draft"]]
    assert_select %[p:contains("the draft boosters are drafted")]
    assert_select %[p a:contains("Faceless One")]
  end

  it "conspiracy draft" do
    get "show", params: {set: "cns", id: "draft"}
    assert_response 200
    assert_select %[p:contains("draft one card")]
    assert_select %[p:contains("command zone")]
    assert_select %[p:contains("free-for-all multiplayer")]
    assert_select %[a[href="/help/rules#section-905"]]
  end

  it "two-headed giant draft and sealed" do
    get "show", params: {set: "bbd", id: "draft"}
    assert_response 200
    # Four packs per team, not three per player
    assert_select %[li a[href="/pack/bbd-draft"]], 4
    assert_select %[p:contains("You draft in a team of two")]
    assert_select %[p:contains("Two-Headed Giant")]
    assert_select %[a[href="/help/rules#section-810"]]

    get "show", params: {set: "bbd", id: "sealed"}
    assert_response 200
    assert_select %[p:contains("what your team gets")]
    assert_select %[p:contains("Two-Headed Giant")]
    assert_select %[a:contains("Open in Sealed simulator")]
  end

  # Formats with random packs only get a placeholder page
  it "placeholder for sealed formats with extra complexity" do
    get "show", params: {set: "dgm", id: "prerelease-sealed"}
    assert_response 200
    assert_equal "Dragon's Maze Prerelease Sealed - #{APP_NAME}", html_document.title
    assert_select %[p:contains("not described on this website yet")]
    assert_select %[a:contains("Open in Sealed simulator")], false
  end

  it "404 for unknown set" do
    get "show", params: {set: "nosuchset", id: "draft"}
    assert_response 404
  end

  it "404 for set without that format" do
    get "show", params: {set: "ust", id: "prerelease-sealed"}
    assert_response 404
  end
end
