require "rails_helper"

RSpec.describe SettingsController, type: :controller do
  render_views

  it "index" do
    get "index"
    assert_response 200
    assert_select %[input[name="default_view"]]
  end

  # The dialog opens on this one, so every format we export has to be offerable
  it "offers every export format, and starts on our own" do
    get "index"
    assert_response 200
    assert_select %[input[name="default_deck_export"]], DeckExporter.codes.size
    DeckExporter.codes.each do |code|
      assert_select %[input[name="default_deck_export"][value="#{code}"]]
    end
    assert_select %[input[name="default_deck_export"][checked]], 1
    assert_select %[input[name="default_deck_export"][value="#{DeckExporter.default.code}"][checked]]
  end
end
