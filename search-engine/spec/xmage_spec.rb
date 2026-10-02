describe "XMage" do
  include_context "db"

  it "has almost all Modern legal cards" do
    # st:modern to ignore reprints in promo sets
    # Most recent sets often come to XMage late or in parts, so this -e: clause needs periodic updating
    assert_search_results "f:modern (st:std or st:modern) -in:xmage -e:msh,hob,fra",
      # text change
      "Glamerdye",
      "Mind Bend",
      "Spectral Shift",
      "Swirl the Mists",
      "Trait Doctoring",
      # ACR, unimplemented since the set's 2024 release, open in https://github.com/magefree/mage/issues/11854
      "Apple of Eden, Isu Relic",
      "Auditore Ambush",
      # other
      "Heirloom Epic",
      "Lorehold, the Historian",
      "Secret of Bloodbending"
  end
end
