describe "P/T queries" do
  include_context "db"

  it "pow:special" do
    assert_search_equal "pow=1+*", "pow=*+1"
    assert_search_include "pow=*", "Krovikan Mist"
    assert_search_results "pow=1+*",
      "Allosaurus Rider",
      "Gaea's Avenger",
      "Haunting Apparition",
      "Lost Order of Jarkeld",
      "Mwonvuli Ooze",
      "Nighthawk Scavenger"
    assert_search_results "pow=2+*",
      "Angry Mob", "Aysen Crusader"
    assert_search_equal "pow>*", "pow>=1+*"
    assert_search_equal "pow>1+*", "pow>=2+*"
    assert_search_equal "pow>1+*", "pow=2+*"
    assert_search_equal "pow=*2", "pow=*²"
    assert_search_results "pow=*2",
      "S.N.O.T."
  end

  it "loy:special" do
    assert_search_results "loy=0", "Jeska, Thrice Reborn", "Dakkon, Shadow Slayer"
    assert_search_equal "loy=x", "loy=X"
    assert_search_results "loy=x", "Nissa, Steward of Elements"
  end

  it "tou:special" do
    # Mostly same as power except 7-*
    assert_search_results "tou=7-*", "Shapeshifter"
    assert_search_results "tou>8-*"
    assert_search_results "tou>2-*", "Shapeshifter"
    assert_search_results "tou>8-*"
    assert_search_results "tou<=8-*", "Shapeshifter"
    assert_search_results "tou<=2-*"
  end

  it "quoting" do
    assert_search_equal %[pow="1+*"], %[pow=1+*]
    assert_search_equal %[tou="1+*"], %[tou=1+*]
    assert_search_equal %[loy="X"], %[loy=X]
  end
end
