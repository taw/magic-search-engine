describe "XMage" do
  include_context "db"

  it "has almost all Modern legal cards" do
    assert_search_results "f:modern -in:xmage -e:khm",
      "Brokkos, Apex of Forever",
      "Glamerdye",
      "Mind Bend",
      "Spectral Shift",
      "Swirl the Mists",
      "Trait Doctoring"
  end
end
