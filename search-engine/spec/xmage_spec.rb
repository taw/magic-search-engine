describe "XMage" do
  include_context "db"

  it "has almost all Modern legal cards" do
    # st:modern to ignore reprints in promo sets
    # Most recent sets often come to XMage late or in parts, so this -e: clause needs periodic updating
    #
    # Base LTR works, but there are extra cards being released post main release as part of LTR set
    assert_search_results "f:modern (st:std or st:modern) -in:xmage -e:mat,woe,ltr,lci,mkm",
      # mutate from graveyard
      "Brokkos, Apex of Forever",
      # text change
      "Glamerdye",
      "Mind Bend",
      "Spectral Shift",
      "Swirl the Mists",
      "Trait Doctoring"
  end
end
