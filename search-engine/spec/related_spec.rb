describe "Spelling" do
  include_context "db"

  it do
    assert_search_results "related:cmc=9",
      "Sift Through Sands", # The Unspeakable
      "Urborg Panther"      # Spirit of the Night
  end

  it "Battleborn partner" do
    assert_search_results "related:Zndrsplt",
      "Okaun, Eye of Chaos"
  end

  it "Domesticated Mammoth" do
    assert_search_results "related:Pacifism",
      "Domesticated Mammoth"
  end

  it "*" do
    assert_search_equal "related:t:*", "related:*"
  end
end
