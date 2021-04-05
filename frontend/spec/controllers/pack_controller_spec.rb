require "rails_helper"

RSpec.describe PackController, type: :controller do
  render_views

  it "list of sets" do
    get "index"
    assert_response 200
    assert_select %[li:contains("Magic 2015")]
    assert_select %[li:contains("Kaladesh Remastered Arena Booster\n(KLR-ARENA)")]
    assert_equal "Packs - #{APP_NAME}", html_document.title
  end
end
