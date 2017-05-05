describe "Spelling" do
  include_context "db"

  it do
    assert_search_results "related:cmc=9",
      "Sift Through Sands", # The Unspeakable
      "Urborg Panther"      # Spirit of the Night
  end
end
