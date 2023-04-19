describe "Stamp" do
  include_context "db"

  it "subset:" do
    assert_search_results %q[subset:"OMG KITTIES!"],
      "Arahbo, Roar of the World",
      "Leonin Warleader",
      "Mirri, Weatherlight Duelist",
      "Qasali Slingers",
      "Regal Caracal"

    assert_search_equal %q[subset:"OMG KITTIES!" or subset:"Look at the Kitties"], "subset:kitties"
  end
end
