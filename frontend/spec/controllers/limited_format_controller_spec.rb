require "rails_helper"

RSpec.describe LimitedFormatController, type: :controller do
  render_views

  it "list of limited formats" do
    get "index"
    assert_response 200
    assert_equal "Limited Formats - #{APP_NAME}", html_document.title
    assert_select %[li:contains("New Phyrexia Draft")]
    assert_select %[li:contains("New Phyrexia Prerelease Sealed")]
  end
end
