describe "Archenemy" do
  include_context "db", "arc"

  it "scheme" do
    assert_search_results 't:scheme o:trample', "Your Will Is Not Your Own", "The Very Soil Shall Shake"
    assert_search_results 't:ongoing o:trample', "The Very Soil Shall Shake"
  end

  it "scheme cards not included unless requested" do
    assert_search_results "o:trample",
      "Armadillo Cloak",
      "Colossal Might",
      "Kamahl, Fist of Krosa",
      "Molimo, Maro-Sorcerer",
      "Rancor",
      "Scion of Darkness"
  end

  it "! search doesnt require explicit flags" do
    assert_search_results "!Your Will Is Not Your Own", "Your Will Is Not Your Own"
  end
end
