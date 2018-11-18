require "rails_helper"

RSpec.describe SealedController, type: :controller do
  render_views

  it "index" do
    get "index"
    assert_response 200
    assert_equal "Sealed - #{APP_NAME}", html_document.title
  end

  it "open some packs" do
    get "index", params: {count: ["1", "2"], set: ["nph", "arn"]}
    assert_response 200
    assert_equal "Sealed - #{APP_NAME}", html_document.title
    assert_select ".card_picture_container", count: 15 + 2 * 8
  end
end
