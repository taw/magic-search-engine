describe "XMage" do
  include_context "db"

  it "has almost all Modern legal cards" do
    assert_search_results "f:modern -in:xmage",
      "Brokkos, Apex of Forever",
      "Glamerdye",
      "Lithoform Engine",
      "Mind Bend",
      "Spectral Shift",
      "Swirl the Mists",
      "Trait Doctoring",
      "Verazol, the Split Current"
  end
end
