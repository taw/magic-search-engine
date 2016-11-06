describe "Innistrad Block" do
  include_context "db", "isd", "dka"

  it "dfg color identity applies to both sides together" do
    "ci:gb".should include_cards "Garruk Relentless"
    "ci:gb".should include_cards "Garruk, the Veil-Cursed"
    "ci:g" .should exclude_cards "Garruk Relentless"
    "ci:g" .should exclude_cards "Garruk, the Veil-Cursed"
    "ci:b" .should exclude_cards "Garruk Relentless"
    "ci:b" .should exclude_cards "Garruk, the Veil-Cursed"
    "ci:wb".should include_cards "Loyal Cathar"
    "ci:wb".should include_cards "Unhallowed Cathar"
    "ci:w" .should exclude_cards "Loyal Cathar"
    "ci:b" .should exclude_cards "Loyal Cathar"
    "ci:w" .should exclude_cards "Unhallowed Cathar"
    "ci:b" .should exclude_cards "Unhallowed Cathar"
  end

  it "dfc color applies to side separately" do
    "c!g" .should include_cards "Garruk Relentless"
    "c!gb".should include_cards "Garruk, the Veil-Cursed"
    "c!w" .should include_cards "Loyal Cathar"
    "c!b" .should include_cards "Unhallowed Cathar"
  end

  it "midword hyphen" do
    "Garruk -Veil-Cursed".should include_cards "Garruk Relentless"
  end

  it "dfc search" do
    "t:Garruk"               .should include_cards "Garruk Relentless", "Garruk, the Veil-Cursed"
    "t:Garruk c:g"           .should include_cards "Garruk Relentless", "Garruk, the Veil-Cursed"
    "t:Garruk c!g"           .should include_cards "Garruk Relentless"
    "t:Garruk c:b"           .should include_cards "Garruk, the Veil-Cursed"
    "t:Garruk c:gb"          .should include_cards "Garruk, the Veil-Cursed"
    "Garruk"                 .should include_cards "Garruk Relentless", "Garruk, the Veil-Cursed"
    "Garruk Relentless"      .should include_cards "Garruk Relentless"
    "Garruk, the Veil-Cursed".should include_cards "Garruk, the Veil-Cursed"
    "is:split"               .should return_no_cards
    "is:flip"                .should return_no_cards
    "is:dfc"                 .should include_cards "Garruk Relentless", "Garruk, the Veil-Cursed"
    "is:dfc t:planeswalker"  .should return_cards "Garruk Relentless", "Garruk, the Veil-Cursed"
    "is:dfc t:artifact"      .should return_cards "Chalice of Death", "Chalice of Life", "Elbrus, the Binding Blade"
    "is:dfc c:c"             .should return_cards "Chalice of Death", "Chalice of Life", "Elbrus, the Binding Blade"
    "is:dfc ci:c"            .should return_cards "Chalice of Death", "Chalice of Life"
    "is:dfc"                 .should equal_search "layout:dfc"
    "not:dfc"                .should equal_search "-layout:dfc"
  end

  it "other:" do
    "c!bgm".should return_cards("Garruk, the Veil-Cursed")
    "other:c!bgm".should return_cards("Garruk Relentless")
    "other:(o:wolf o:token)".should return_cards(
      "Garruk Relentless",
      "Garruk, the Veil-Cursed",
      "Mayor of Avabruck",
      "Ravager of the Fells"
    )
    "other:-t:werewolf c:r".should return_cards("Homicidal Brute")
  end

  it "//" do
    "t:planeswalker //"  .should return_cards(
      "Garruk Relentless",
      "Garruk, the Veil-Cursed",
    )
    "t:human // t:insect".should return_cards(
      "Delver of Secrets",
      "Insectile Aberration",
    )
  end
end
