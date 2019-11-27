require "rails_helper"

RSpec.describe ArtistController, type: :controller do
  render_views

  it "list of artists" do
    get "index"
    assert_response 200
    assert_select %Q[a:contains("Yang Hong")]
    assert_select %Q[li:contains("Yang Hong\n(8 cards)")]
    assert_equal "Artists - #{APP_NAME}", html_document.title
  end

  it "actual artist" do
    get "show", params: { id: "steve_ellis" }
    assert_response 200
  end

  it "fake artist" do
    get "show", params: { id: "katy_perry" }
    assert_response 404
  end
end
