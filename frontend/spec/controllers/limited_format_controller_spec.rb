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

  # Formats with a faction choice, random packs, or an unusual way of playing
  # them only get a placeholder page
  it "placeholder for sealed formats with extra complexity" do
    get "show", params: {set: "rtr", id: "prerelease-sealed"}
    assert_response 200
    assert_equal "Return to Ravnica Prerelease Sealed - #{APP_NAME}", html_document.title
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
