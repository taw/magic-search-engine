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

  it "fake set" do
    get "show", params: {id: "lolwtf"}
    assert_response 404
  end

  it "verify scans" do
    get "show", params: {id: "akh"}
    assert_response 200
    assert_equal "Amonkhet - #{APP_NAME}", html_document.title
  end
end
