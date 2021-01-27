describe "8th Edition" do
  include_context "db", "8ed"

  it "type line apostrophe" do
    "Urza’s"  .should include_cards "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    "Urza’s"  .should include_cards "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    "urza's"  .should include_cards "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    "urza"    .should include_cards "Urza's Armor", "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    "o:Urza’s".should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    "o:urza's".should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    "o:urza"  .should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    "t:Urza’s".should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    "t:urza's".should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
    "t:urza"  .should include_cards "Urza's Mine", "Urza's Power Plant", "Urza's Tower"
  end

  it "type line hyphen" do
    "t:power-plant"         .should include_cards "Urza's Power Plant"
    "t:power\u2212plant"    .should include_cards "Urza's Power Plant"
    't:"power plant"'       .should return_no_cards
    't:"power-plant"'       .should include_cards "Urza's Power Plant"
    %[t:"power\u2212plant"].should include_cards "Urza's Power Plant"
    "o:power-plant"         .should include_cards "Urza's Mine", "Urza's Tower"
    "o:power\u2212plant"    .should include_cards "Urza's Mine", "Urza's Tower"
    'o:"power plant"'       .should return_no_cards
    'o:"power-plant"'       .should include_cards "Urza's Mine", "Urza's Tower"
    %[o:"power\u2212plant"].should include_cards "Urza's Mine", "Urza's Tower"
  end
end
