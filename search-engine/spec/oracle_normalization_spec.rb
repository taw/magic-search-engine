# Card text is normalized when the index is built - accents stripped, curly quotes and
# minus signs folded to ASCII, mana symbols left in the one order the cards print them.
# The query has to go through that exact same normalization or it can never match, and
# it has to do so whether or not it uses ~.

describe "Oracle normalization" do
  include_context "db"

  # Cards print each two-part symbol in one fixed order. Queries may write it either way
  # round, with or without the slash, in either case - they all mean the same symbol.
  it "normalizes mana symbols however the query writes them" do
    ConditionOracle::MANA_NORMALIZATION.each_value do |symbol|
      a, b = symbol[1..-2].split("/")
      expected = search(%[o:"#{symbol}"]).sort
      ["{#{b}/#{a}}", "{#{a}#{b}}", "{#{b}#{a}}", symbol.downcase, "{#{b.downcase}/#{a.downcase}}"].each do |written|
        search(%[o:"#{written}"]).sort.should eq(expected),
          "#{written} should find the same cards as #{symbol}"
      end
    end
  end

  # One entry per symbol which actually turns up in Oracle text. {W/B} is the most
  # common of them and was the one the table used to be missing.
  it "knows the symbols which appear in Oracle text" do
    assert_search_include %[o:"{W/B}"], "Alesha, Who Smiles at Death"
    assert_search_include %[o:"{B/W}"], "Alesha, Who Smiles at Death"
    assert_search_include %[o:"{WB}"],  "Alesha, Who Smiles at Death"
    # 2-brid and colorless Phyrexian do turn up, despite what the old comment claimed
    assert_search_include %[o:"{2/B}"], "Tazri, Beacon of Unity"
    assert_search_include %[o:"{B/2}"], "Tazri, Beacon of Unity"
    assert_search_include %[o:"{C/P}"], "Kozilek, Compleated"
    assert_search_include %[o:"{P/C}"], "Kozilek, Compleated"
  end

  # ~ queries used to take a different route through normalization than plain ones,
  # so anything needing normalization was dropped the moment a ~ appeared
  it "normalizes the same way with ~ as without" do
    assert_search_include %[o:"whenever ~ attacks, you may pay {W/B}"],
      "Alesha, Who Smiles at Death"
    assert_search_include %[o:"whenever ~ attacks, you may pay {B/W}"],
      "Alesha, Who Smiles at Death"
    assert_search_include %[o:"whenever ~ attacks, you may pay {WB}"],
      "Alesha, Who Smiles at Death"
  end

  # Diacritics are stripped from card text, so a query carrying them has to be stripped
  # to match - "Altaïr" on the card is "Altair" by the time it is searched
  it "strips diacritics from the query" do
    assert_search_include %[o:"Altaïr"], "Altaïr Ibn-La'Ahad"
    assert_search_include %[o:"Altair"], "Altaïr Ibn-La'Ahad"
    assert_search_include %[o:"Adéwalé"], "Adéwalé, Breaker of Chains"
    assert_search_include %[o:"Adewale"], "Adéwalé, Breaker of Chains"
    # ... including when a ~ is present, and when ~ itself stands for an accented name
    assert_search_include %[o:"whenever ~ attacks, exile up to one target assassin"],
      "Altaïr Ibn-La'Ahad" # short name is "Altaïr"
    assert_search_include %[o:"when ~ enters, revéal the top six cards"],
      "Adéwalé, Breaker of Chains"
    assert_search_include %[o:"when ~ enters, reveal the top six cards"],
      "Adéwalé, Breaker of Chains"
  end

  # Cards use a typographic apostrophe, queries are typed with either
  it "folds curly quotes to ASCII" do
    assert_search_include %q[o:"where x is ~'s power"], "Agatha of the Vile Cauldron"
    assert_search_include %q[o:"where x is ~’s power"], "Agatha of the Vile Cauldron"
    assert_search_include %q[o:"agatha's power"], "Agatha of the Vile Cauldron"
    assert_search_include %q[o:"agatha’s power"], "Agatha of the Vile Cauldron"
  end
end
