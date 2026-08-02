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

  it "no page for sealed formats yet" do
    get "show", params: {set: "nph", id: "prerelease-sealed"}
    assert_response 404
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
