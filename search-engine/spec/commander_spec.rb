describe "is:commander" do
  include_context "db"

  # arguable if banned cards should be included,
  # but there are multiple commander-like formats
  # with multiple banlists

  it "includes all unusual commanders" do
    assert_search_include "is:commander",
      "Erayo, Soratami Ascendant",
      "Daretti, Scrap Savant",
      "Agrus Kos, Wojek Veteran",
      "Griselbrand",
      "Bruna, the Fading Light",
      "Ulrich of the Krallenhorde",
      "The Legend of Arena"
  end

  it "does not include other sides of commander cards" do
    assert_search_exclude "is:commander",
      "Erayo's Essence",
      "Autumn-Tail, Kitsune Sage",
      "Brisela, Voice of Nightmares",
      "Hanweir, the Writhing Township",
      "Ormendahl, Profane Prince",
      "Ulrich, Uncontested Alpha",
      "Withengar Unbound",
      "Elbrus, the Binding Blade"
  end

  it "is:commander" do
    # Some C14 commanders got reprited
    assert_search_equal_cards "is:commander",
      "(is:primary t:legendary t:creature) OR (t:planeswalker e:c14,c18,bbd,cmr) OR (t:saga e:htr18)"
  end

  it "is:brawler" do
    assert_search_equal_cards "is:brawler", "(is:primary t:legendary t:creature) OR (is:primary t:legendary t:planeswalker)"
  end
end
