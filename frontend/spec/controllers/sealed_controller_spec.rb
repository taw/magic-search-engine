require "rails_helper"

RSpec.describe SealedController, type: :controller do
  render_views

  it "index" do
    get "index"
    assert_response 200
    assert_equal "Sealed - #{APP_NAME}", html_document.title
  end

  it "open some packs" do
    get "index", params: {count: ["1", "2"], set: ["nph-draft", "arn"]}
    assert_response 200
    assert_equal "Sealed - #{APP_NAME}", html_document.title
    assert_select ".card_picture_container", count: 15 + 2 * 8
  end

  # A pack the player got at random out of a few, like the allied guild booster
  # of the Dragon's Maze prerelease
  it "open a pack picked at random out of a few" do
    sizes = 20.times.map do
      get "index", params: {count: ["1"], set: ["nph-draft|arn"]}
      assert_response 200
      css_select(".card_picture_container").size
    end
    assert_equal [8, 15], sizes.uniq.sort
  end

  it "open a Dragon's Maze prerelease pool" do
    get "index", params: {
      count: ["4", "1", "1"],
      set: [
        "dgm-draft",
        "rtr-prerelease-azorius",
        "gtc-prerelease-orzhov|gtc-prerelease-dimir|gtc-prerelease-boros|gtc-prerelease-simic",
      ],
    }
    assert_response 200
    assert_select ".card_picture_container", count: 6 * 15
    # A random pack is not a booster type, so the dropdowns get an extra option
    # for it, or the row would have nothing selected
    random = "gtc-prerelease-orzhov|gtc-prerelease-dimir|gtc-prerelease-boros|gtc-prerelease-simic"
    assert_select %[select#set_2 option[selected][value=?]], random
    assert_select %[select#set_0 option[value=?]], random
    assert_select %[option:contains("Random: Gatecrash Prerelease Pack Orzhov, ")]
  end

  it "no random option without a random pack" do
    get "index"
    assert_response 200
    assert_select %[option:contains("Random: ")], false
  end
end
