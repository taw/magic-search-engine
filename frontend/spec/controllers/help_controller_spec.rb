require "rails_helper"

RSpec.describe HelpController, type: :controller do
  render_views

  it "smoke test" do
    get "syntax"
    assert_response 200
    assert_select %Q[h3:contains("Search Help")]
    assert_equal "Syntax - #{APP_NAME}", html_document.title
  end

  it "comprehensive rules" do
    get "rules"
    assert_response 200
    assert_select %Q[*:contains("Magic: The Gathering Comprehensive Rules")]
    assert_equal "Magic: The Gathering Comprehensive Rules - #{APP_NAME}", html_document.title
  end

  it "contact" do
    get "contact"
    assert_response 200
    assert_select %Q[div:contains("You can contact me by")]
    assert_equal "Contact - #{APP_NAME}", html_document.title
  end
end
