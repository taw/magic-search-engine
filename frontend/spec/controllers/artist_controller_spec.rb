require "rails_helper"

RSpec.describe ArtistController, type: :controller do
  render_views

  it "list of artists" do
    get "index"
    assert_response 200
    assert_select %[a:contains("Yang Hong")]
    assert_select %[li:contains("Yang Hong\n(9 cards)")]
    assert_equal "Artists - #{APP_NAME}", html_document.title
  end

  it "actual artist" do
    get "show", params: {id: "steve_ellis"}
    assert_response 200
    assert_equal "Steve Ellis - #{APP_NAME}", html_document.title
    assert_select %[h3:contains("Steve Ellis")]
    assert_select %[.results_summary:contains("Steve Ellis drew")]
  end

  # Ten sets to a page, newest first, and no set on two pages
  it "paginates by set" do
    get "show", params: {id: "rk_post"}
    assert_response 200
    first_page = css_select("h3.col-12").map(&:text)

    get "show", params: {id: "rk_post", page: "2"}
    assert_response 200
    second_page = css_select("h3.col-12").map(&:text)

    assert_equal 10, first_page.size
    assert_equal 10, second_page.size
    assert_empty first_page & second_page
  end

  it "fake artist" do
    get "show", params: {id: "katy_perry"}
    assert_response 404
  end
end
