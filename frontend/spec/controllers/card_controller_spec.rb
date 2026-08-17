require "rails_helper"

RSpec.describe CardController, type: :controller do
  render_views

  # show
  it "show card" do
    get "show", params: {set: "nph", id: "1"}
    assert_response 200
    assert_select %[.cardinfo:contains("Karn Liberated")]
    assert_equal "Karn Liberated - #{APP_NAME}", html_document.title
  end

  it "bad set" do
    get "show", params: {set: "lolwtf", id: "1"}
    assert_response 404
  end

  # Black Lotus hasn't moved on any banlist in decades
  it "show legalities" do
    get "show", params: {set: "lea", id: "232"}
    assert_response 200
    legalities = css_select(".legalities li").map{|li| li.text.split(/\s+/).join(" ").strip}
    assert_includes legalities, "restricted Vintage"
    assert_includes legalities, "banned Legacy"
    assert_select %[.legalities a[href="/format/vintage"]]
    assert_select %[.legalities i.legality-restricted]
  end

  it "bad collector number" do
    get "show", params: {set: "nph", id: "1000"}
    assert_response 404
  end

  # gallery
  it "show card gallery - bad set" do
    get "gallery", params: {set: "lolwtf", id: "1"}
    assert_response 404
  end

  it "show card gallery - bad collector number" do
    get "gallery", params: {set: "nph", id: "1000"}
    assert_response 404
  end

  it "show card gallery - not first printing" do
    get "gallery", params: {set: "nph", id: "168"}
    assert_response 302
    assert_redirected_to action: "gallery", set: "lea", id: "288"
  end

  it "show card gallery - not first card in first printing" do
    get "gallery", params: {set: "lea", id: "289"}
    assert_response 302
    assert_redirected_to action: "gallery", set: "lea", id: "288"
  end

  it "show card gallery - first card in first printing" do
    get "gallery", params: {set: "lea", id: "288"}
    assert_response 200
    assert_equal "Island - #{APP_NAME}", html_document.title
    assert_select %[.results_summary:contains("Island has")]
  end

  # Ten sets to a page, newest first, and no set on two pages
  it "show card gallery - paginates by set" do
    get "gallery", params: {set: "lea", id: "288"}
    assert_response 200
    first_page = css_select("h3.col-12").map(&:text)

    get "gallery", params: {set: "lea", id: "288", page: "2"}
    assert_response 200
    second_page = css_select("h3.col-12").map(&:text)

    assert_equal 10, first_page.size
    assert_equal 10, second_page.size
    assert_empty first_page & second_page
  end

  # search
  it "search nothing" do
    get "index"
    assert_response 200
    assert_select ".cardinfo", 0
    assert_select ".results_summary", 0
    assert_equal "#{APP_NAME}", html_document.title
  end

  it "search all" do
    get "index", params: {q: "sort:new"}
    assert_response 200
    assert_select ".cardinfo", 25
    assert_equal "sort:new - #{APP_NAME}", html_document.title
  end

  it "search page 2" do
    get "index", params: {q: "sort:new", page: "2"}
    assert_response 200
    assert_select ".cardinfo", 25
    assert_equal "sort:new - #{APP_NAME}", html_document.title
  end

  it "view:full" do
    get "index", params: {q: "t:planeswalker view:full"}
    assert_response 200
    assert_select ".cardinfo"
  end

  it "view:checklist" do
    get "index", params: {q: "t:planeswalker view:checklist"}
    assert_response 200
  end

  it "nothing found" do
    get "index", params: {q: "italian spiderman"}
    assert_response 200
    assert_select ".cardinfo", 0
    assert_select %[.results_summary:contains("No cards found")]
    assert_equal "italian spiderman - #{APP_NAME}", html_document.title
  end

  it "search something" do
    get "index", params: {q: "Karn Liberated"}
    assert_response 200
    assert_select %[.cardinfo:contains("Karn Liberated")]
    assert_select %[.results_summary:contains("1 card found")]
    assert_equal "Karn Liberated - #{APP_NAME}", html_document.title
  end

  it "view:default" do
    get "index", params: {q: "t:planeswalker"}
    assert_response 200
    assert_select ".card_picture_container", 25
    assert_select ".card_title", 25
  end

  it "view:images" do
    get "index", params: {q: "t:planeswalker view:images"}
    assert_response 200
    assert_select ".card_picture_container", 60
    assert_select ".card_title", 0
  end

  it "view:text" do
    get "index", params: {q: "t:planeswalker view:text"}
    assert_response 200
    assert_select ".card_picture_container", 0
    assert_select ".card_title", 60
  end

  # settings page saves this cookie, and it picks the view for every search
  describe "default_view cookie" do
    it "picks the view" do
      request.cookies["default_view"] = "images"
      get "index", params: {q: "t:planeswalker"}
      assert_response 200
      assert_select ".card_picture_container", 60
      assert_select ".card_title", 0
    end

    it "is overridden by view: in the query" do
      request.cookies["default_view"] = "images"
      get "index", params: {q: "t:planeswalker view:text"}
      assert_response 200
      assert_select ".card_picture_container", 0
      assert_select ".card_title", 60
    end

    it "falls back to the default view if it's nonsense" do
      request.cookies["default_view"] = "lolwtf"
      get "index", params: {q: "t:planeswalker"}
      assert_response 200
      assert_select ".card_picture_container", 25
      assert_select ".card_title", 25
    end
  end

  describe "warnings" do
    it "reports queries it only half understood" do
      get "index", params: {q: "Karn Libarated"}
      assert_response 200
      assert_select ".warning", text: %[Trying spelling "liberated" in addition to "libarated"]
      assert_select %[.cardinfo:contains("Karn Liberated")]
    end

    it "reports queries it did not understand at all" do
      get "index", params: {q: "is:foobar"}
      assert_response 200
      assert_select %[.warning:contains("Unrecognized token: is:foobar")]
      assert_select %[.results_summary:contains("No cards found")]
    end

    it "has no warnings for a query it understood" do
      get "index", params: {q: "Karn Liberated"}
      assert_response 200
      assert_select ".warning", 0
    end
  end

  # sort:random has to give the same page 2 as page 1, so the seed is part of
  # the pagination links
  describe "sort:random" do
    it "rolls a seed and keeps it in the pagination links" do
      get "index", params: {q: "t:planeswalker sort:random"}
      assert_response 200
      assert_select %[a[href*="random_seed="]]
    end

    it "returns the same cards for the same seed" do
      names = 2.times.map do
        get "index", params: {q: "t:planeswalker sort:random", random_seed: "12345"}
        assert_response 200
        css_select(".card_title").map(&:text)
      end
      assert_equal names[0], names[1]
      refute_empty names[0]
    end
  end

  # color indicator
  it "devoid" do
    get "index", params: {q: "Complete Disregard"}
    text = html_document.at(".oracle").inner_html.strip.gsub("<br>", "\n")
    assert_equal "Devoid\nExile target creature with power 3 or less.", text
  end

  it "color indicator" do
    get "index", params: {q: "Ancestral Vision"}
    text = html_document.at(".oracle").inner_html.strip.gsub("<br>", "\n")
    assert_includes text, "(Color indicator: Ancestral Vision is blue)"
  end

  it "DFCs" do
    get "index", params: {q: "Garruk, the Veil-Cursed"}
    text = html_document.at(".oracle").inner_html.strip.gsub("<br>", "\n")
    assert_includes text, "(Color indicator: Garruk, the Veil-Cursed is black and green)"
  end

  it "Nicol Bolas, the Arisen" do
    get "index", params: {q: "Nicol Bolas, the Arisen"}
    text = html_document.at(".oracle").inner_html.strip.gsub("<br>", "\n")
    assert_includes text, "(Color indicator: Nicol Bolas, the Arisen is blue, black, and red)"
  end

  it "Ghostfire" do
    get "index", params: {q: "Ghostfire"}
    text = html_document.at(".oracle").inner_html.strip.gsub("<br>", "\n")
    assert_equal "Ghostfire is colorless.\nGhostfire deals 3 damage to any target.", text
  end
end
