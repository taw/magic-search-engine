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

  it "mtgo draft" do
    get "show", params: {set: "vma", id: "mtgo-draft"}
    assert_response 200
    assert_equal "Vintage Masters MTGO Draft - #{APP_NAME}", html_document.title
    assert_select %[p:contains("only ever happened")]
    assert_select %[li a[href="/pack/vma-mtgo"]], 3
    assert_select %[p:contains("draft one card")]
  end

  # Dominaria was drafted in paper too, just out of different boosters
  it "arena draft of a paper set" do
    get "show", params: {set: "dom", id: "arena-draft"}
    assert_response 200
    assert_equal "Dominaria Arena Draft - #{APP_NAME}", html_document.title
    assert_select %[p:contains("not the same format as the paper draft")]
    assert_select %[p:contains("only ever happened")], false
    assert_select %[li a[href="/pack/dom-arena"]], 3
    assert_select %[p:contains("draft one card")]
  end

  it "arena draft of an Arena only set" do
    get "show", params: {set: "akr", id: "arena-draft"}
    assert_response 200
    assert_equal "Amonkhet Remastered Arena Draft - #{APP_NAME}", html_document.title
    assert_select %[p:contains("only ever happened")]
    assert_select %[li a[href="/pack/akr-arena"]], 3
  end

  # Shadows over Innistrad Remastered was drafted four times, once per group of
  # its bonus sheet, so each of those runs has a page of its own
  it "arena draft of a set whose boosters rotated" do
    get "show", params: {set: "sir", id: "arena-draft-3"}
    assert_response 200
    assert_equal "Shadows over Innistrad Remastered Arena Draft: Morbid and Macabre - #{APP_NAME}", html_document.title
    assert_select %[p:contains("only ever happened")]
    assert_select %[p:contains("four drafts rather than one")]
    assert_select %[li a[href="/pack/sir-arena-3"]], 3
    assert_select %[p:contains("draft one card")]
  end

  it "lists every run of a draft whose boosters rotated" do
    get "index"
    assert_response 200
    assert_select %[a[href="/limited_format/pio/arena-draft-1"]:contains("Pioneer Masters Arena Draft: Planeswalkers")]
    assert_select %[a[href="/limited_format/pio/arena-draft-3"]:contains("Pioneer Masters Arena Draft: Devotion")]
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

  # Formats with packs picked at random out of a list
  it "sealed with random packs" do
    get "show", params: {set: "dgm", id: "prerelease-sealed"}
    assert_response 200
    assert_equal "Dragon's Maze Prerelease Sealed - #{APP_NAME}", html_document.title
    # One pool per guild, each with its own pack and its own allied guilds
    assert_select %[h4:contains("Azorius")]
    assert_select %[li a[href="/pack/rtr-prerelease-azorius"]]
    assert_select %[li:contains("1x allied guild booster")]
    assert_select %[li a[href="/pack/gtc-prerelease-orzhov"]]
    assert_select %[li a[href="/pack/gtc-prerelease-simic"]]
    assert_select %[a:contains("Open in Sealed simulator")], 10
  end

  # Two packs shuffled together, with no deck construction at all
  it "jumpstart" do
    get "show", params: {set: "dmu", id: "jumpstart"}
    assert_response 200
    assert_equal "Dominaria United Jumpstart - #{APP_NAME}", html_document.title
    assert_select %[li:contains("2x") a[href="/pack/dmu-jumpstart"]:contains("Dominaria United Jumpstart Booster")]
    assert_select %[p:contains("no deck construction")]
    assert_select %[p:contains("any other Jumpstart set")]
    # Normal sealed rules don't apply
    assert_select %[p:contains("build a 40 card deck")], false
    assert_select %[a:contains("Open in Sealed simulator")] do |links|
      assert_includes links.first["href"], "count%5B%5D=2"
      assert_includes links.first["href"], "set%5B%5D=dmu-jumpstart"
    end
  end

  # A set whose name already says Jumpstart names the format itself
  it "jumpstart of a jumpstart set" do
    get "show", params: {set: "j25", id: "jumpstart"}
    assert_response 200
    assert_equal "Foundations Jumpstart - #{APP_NAME}", html_document.title
    assert_select %[li a[href="/pack/j25-jumpstart"]]
  end

  # The Lord of the Rings has two volumes of Jumpstart packs, and a game is any
  # two of them, so every pack of the pool is picked at random
  it "jumpstart of a set with two volumes of packs" do
    get "show", params: {set: "ltr", id: "jumpstart"}
    assert_response 200
    assert_select %[li:contains("2x Jumpstart booster")]
    assert_select %[li a[href="/pack/ltr-jumpstart"]]
    assert_select %[li a[href="/pack/ltr-jumpstart-v2"]]
    assert_select %[a:contains("Open in Sealed simulator")] do |links|
      assert_includes links.first["href"], "set%5B%5D=ltr-jumpstart%7Cltr-jumpstart-v2"
    end
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
