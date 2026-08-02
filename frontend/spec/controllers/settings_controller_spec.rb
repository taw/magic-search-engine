require "rails_helper"

RSpec.describe SettingsController, type: :controller do
  render_views

  it "index" do
    get "index"
    assert_response 200
    assert_select %[input[name="default_view"]]
  end
end
