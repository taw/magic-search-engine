require "rails_helper"

RSpec.describe SetController, type: :controller do
  render_views

  it "list of sets" do
    get "index"
    assert_response 200
    assert_select %[a:contains("Magic 2015")]
    assert_select %[li:contains("Magic 2015\n(M15, 284 cards)")]
    assert_equal "Sets - #{APP_NAME}", html_document.title
  end

  it "actual set" do
    get "show", params: {id: "nph"}
    assert_response 200
    assert_select %[.results_summary:contains("New Phyrexia contains 175 cards.")]
    assert_select %[.results_summary:contains("It is part of Scars of Mirrodin block.")]
    assert_select %[h3:contains("New Phyrexia")]
    assert_select %[a:contains("Karn Liberated")]
    assert_equal "New Phyrexia - #{APP_NAME}", html_document.title
  end

  it "release dates" do
    get "show", params: {id: "prna"}
    assert_response 200
    expect(css_select(".results_summary").text).to match(/Released: 2019-01-25/)
    expect(css_select(".results_summary").text).to match(/Individual cards released between 2019-01-25 and 2021-12-08/)
  end

  it "links everything else we know about the set" do
    get "show", params: {id: "nph"}
    assert_response 200
    assert_select %[a[href="/pack/nph-draft"]:contains("New Phyrexia Draft Booster")]
    assert_select %[a[href="/product/nph/new_phyrexia_booster_box"]:contains("New Phyrexia Booster Box")]
    assert_select %[a[href="/limited_format/nph/draft"]:contains("New Phyrexia Draft")]
    assert_select %[a[href="/deck/nph/war-of-attrition"]]
  end

  # The summary is only worth a page of its own, so page 2 is just cards
  it "paginates" do
    get "show", params: {id: "nph"}
    assert_response 200
    assert_select ".card_row", 25
    first_page = css_select(".card_row .card_title").map(&:text)

    get "show", params: {id: "nph", page: "2"}
    assert_response 200
    assert_select ".card_row", 25
    assert_select ".results_summary", text: ""
    assert_empty first_page & css_select(".card_row .card_title").map(&:text)
  end

  it "fake set" do
    get "show", params: {id: "lolwtf"}
    assert_response 404
  end

  it "verify scans" do
    get "show", params: {id: "akh"}
    assert_response 200
    assert_equal "Amonkhet - #{APP_NAME}", html_document.title
  end

  it "verify_scans action" do
    get "verify_scans", params: {id: "akh"}
    assert_response 200
    assert_equal "Amonkhet - #{APP_NAME}", html_document.title
  end

  it "verify_scans action - fake set" do
    get "verify_scans", params: {id: "lolwtf"}
    assert_response 404
  end

  it "missing_scans action" do
    get "missing_scans", params: {id: "akh"}
    assert_response 200
    assert_equal "Amonkhet - #{APP_NAME}", html_document.title
  end

  it "missing_scans action - fake set" do
    get "missing_scans", params: {id: "lolwtf"}
    assert_response 404
  end
end
