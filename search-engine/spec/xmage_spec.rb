describe "XMage" do
  include_context "db"

  it "has almost all Modern legal cards" do
    assert_search_results "f:modern -in:xmage -e:mh2,pmh2,afr,pafr,afc,plg21",
      "Brokkos, Apex of Forever",
      "Glamerdye",
      "Mind Bend",
      "Spectral Shift",
      "Swirl the Mists",
      "Trait Doctoring"
  end
end
