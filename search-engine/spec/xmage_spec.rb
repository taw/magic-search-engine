describe "XMage" do
  include_context "db"

  it "has almost all Modern legal cards" do
    # st:modern to ignore reprints in promo sets
    assert_search_results "f:modern (st:std or st:modern) -in:xmage -e:afr",
      "Brokkos, Apex of Forever",
      "Glamerdye",
      "Mind Bend",
      "Spectral Shift",
      "Swirl the Mists",
      "Trait Doctoring"
  end
end
