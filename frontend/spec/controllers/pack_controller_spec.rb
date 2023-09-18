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

  it "set without packs" do
    get "show", params: {id: "c15"}
    assert_response 404
  end

  it "fake pack" do
    get "show", params: {id: "lolwtf"}
    assert_response 404
  end
end
