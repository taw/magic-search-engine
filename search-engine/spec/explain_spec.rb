# One example per condition class with a bespoke Query#explain (i.e. everything
# that isn't just falling back to Condition's default `` matches `#{self}` ``),
# plus a handful of integration tests for how AND/OR/NOT compose.
describe "Query#explain" do
  include_context "db"

  it "e:" do
    assert_explains "e:fra", %[the set is "fra"]
    assert_explains "e:isd,dka", %[the set is "isd" or "dka"]
  end

  it "c=/c>=/c<= (colors)" do
    assert_explains "c=w", "the colors is W"
    assert_explains "c=gr", "the colors is RG"
    assert_explains "c>=gr", "the colors includes at least RG"
    assert_explains "c<=gr", "the colors is at most RG"
    assert_explains "c=4", "the colors is 4 colors"
    assert_explains "c=colorless", "the colors is 0 colors"
    assert_explains "c=multicolor", "the colors includes at least 2 colors"
  end

  it "ci= (color identity)" do
    assert_explains "ci=temur", "the color identity is URG"
  end

  it "ind= (color indicator)" do
    assert_explains "ind=r", "the color indicator is R"
    assert_explains "ind>=r", "the color indicator includes at least R"
  end

  it "t=/t>=/t>/t<=/t< (type expression)" do
    assert_explains "t=creature", "the card types are exactly creature"
    assert_explains %[t="land forest"], "the card types are exactly land and forest"
    assert_explains %[t>="land forest"], "the card types include land and forest"
    assert_explains %[t>"land forest"], "the card types include land and forest, plus at least one more"
    assert_explains "t<=creature", "the card types are a subset of creature"
    assert_explains "t<creature", "the card types are a strict subset of creature"
  end

  it "t: (bare type list)" do
    assert_explains "t:goblin", "the card types include goblin"
    assert_explains %[t:"goblin warrior"], "the card types include goblin and warrior"
    assert_explains "t:*", "the card types include any type"
  end

  it "mv=/pow=/tou=/pt=/loy=/... (card value expression)" do
    assert_explains "mv=3", "the mana value is 3"
    assert_explains "mv>=3", "the mana value is at least 3"
    assert_explains "mv<2", "the mana value is less than 2"
    assert_explains "pow>tou", "the power is more than the toughness"
    assert_explains "pt>=8", "the power and toughness total is at least 8"
    assert_explains "pt=1+*", "the power and toughness total is 1+*"
    assert_explains "tou=mv", "the toughness is the mana value"
    assert_explains "loyalty=3", "the starting loyalty is 3"
    assert_explains "defense=7", "the defense is 7"
    assert_explains "hand=-2", "the hand size bonus is -2"
    assert_explains "life>=+5", "the life bonus is at least +5"
    assert_explains "decklimit=any", "the deck limit is any"
  end

  it "mv:even / mv:odd (parity)" do
    assert_explains "mv:even", "the mana value is even"
    assert_explains "mv:odd", "the mana value is odd"
  end

  it "o: (Oracle text)" do
    assert_explains "o:delve", %[the Oracle text includes "delve"]
  end

  it "fo: (Oracle text including reminder text)" do
    assert_explains "fo:flying", %[the Oracle text, including reminder text, includes "flying"]
  end

  it "r:/r>= (rarity)" do
    assert_explains "r:common", "the rarity is common"
    assert_explains "r>=rare", "the rarity is at least rare"
  end

  it "o:/regex/ (Oracle text regex)" do
    assert_explains "o:/dragon/", "the Oracle text matches the regex `/dragon/`"
  end

  it "fo:/regex/ (full Oracle text regex)" do
    assert_explains "fo:/dragon/", "the Oracle text, including reminder text, matches the regex `/dragon/`"
  end

  it "n:/regex/ (name regex)" do
    assert_explains "n:/^Ae/", "the name matches the regex `/^Ae/`"
  end

  it "t:/regex/ (type line regex)" do
    assert_explains "t:/^Legendary/", "the type line matches the regex `/^Legendary/`"
  end

  it "ft:/regex/ (flavor text regex)" do
    assert_explains "ft:/ice/", "the flavor text matches the regex `/ice/`"
  end

  it "a:/regex/ (artist regex)" do
    assert_explains "a:/guay/", "the artist credit matches the regex `/guay/`"
  end

  it "<lang>:/regex/ (foreign name regex)" do
    assert_explains "de:/dragon/", "the de name matches the regex `/dragon/`"
    assert_explains "foreign:/dragon/", "the foreign name matches the regex `/dragon/`"
  end

  it "number:/regex/ (collector number regex)" do
    assert_explains "number:/★/", "the collector number matches the regex `/★/`"
  end

  it "rulings:/regex/ (rulings regex)" do
    assert_explains "rulings:/twitter/", "the rulings matches the regex `/twitter/`"
  end

  it "border:/frame:/stamp:/layout:/promo:/st: (simple field conditions)" do
    assert_explains "border:black", "the border is black"
    assert_explains "frame:legendary", "the card has the legendary frame effect"
    assert_explains "stamp:acorn", "the card has the acorn security stamp"
    assert_explains "layout:saga", "the card's layout is saga"
    assert_explains "promo:fnm", "the card is a fnm promo"
    assert_explains "st:core", "the set's type is core"
  end

  it "w:/sig:/keyword:/a:/ft:/fn: (plain substring fields)" do
    assert_explains "w:izzet", %[the watermark includes "izzet"]
    assert_explains "keyword:flying", "the card has the flying keyword"
    assert_explains "a:argyle", %[the artist credit includes "argyle"]
    assert_explains "ft:chandra", %[the flavor text includes "chandra"]
    assert_explains "fn:mothra", %[the flavor name includes "mothra"]
  end

  it "rulings: and lore:" do
    assert_explains %[rulings:"Blood Moon"], %[the rulings include "blood moon"]
    assert_explains "lore:gideon", %[the name, type, or flavor text mentions "gideon"]
  end

  it "number: (collector number)" do
    assert_explains "number:117", "the collector number is 117"
    assert_explains "number<=set", "the collector number is at most the set's base size"
  end

  it "has:/in: (printing-level existence checks)" do
    assert_explains "has:watermark", "the card has a watermark"
    assert_explains "has:signature", "the card has a signature"
    assert_explains "in:foil", "the card has a foil version"
    assert_explains "in:arena", "the card has a printing available on Arena"
  end

  it "variant: (Arena/foreign/misprint variants)" do
    assert_explains "variant:misprint", "the card is a misprinted variant of another card in the same set"
    assert_explains "variant:arena", "the card is an Arena-only variant of another card in the same set"
  end

  context "is: flags" do
    # Structural completeness check: every ConditionIs* class should now have a
    # real explanation, not the generic `` matches `#{self}` `` fallback.
    it "every is: flag has a real explanation, not the generic fallback" do
      is_classes = ObjectSpace.each_object(Class).select{|c| c.name.to_s.start_with?("ConditionIs") }
      still_falling_back = is_classes.select{|c| c.new.explain.start_with?("matches `") }
      still_falling_back.should eq([])
    end

    it "a representative sample reads as English" do
      assert_explains "is:vertical", "the card is vertical, not a Plane, Phenomenon, or Battle"
      assert_explains "is:commander", "the card is playable as a Commander"
      assert_explains "is:foil", "the card has a foil version"
      assert_explains "is:permanent", "the card is a permanent (artifact, battle, creature, enchantment, land, or planeswalker)"
      assert_explains "is:reprint", "the card is a reprint"
      assert_explains "is:unique", "the card has never been reprinted"
    end

    it "land cycle nicknames" do
      assert_explains "is:shockland", "the card is a shockland"
      assert_explains "is:fetchland", "the card is a fetchland"
      assert_explains "is:dual", "the card is one of the original dual lands"
    end

    it "the handful with sensitive or unusual content" do
      assert_explains "is:power9", "the card is one of the Power Nine"
      assert_explains "is:racist", "the card is on Wizards' list of cards with racist names or imagery"
      assert_explains "is:attraction", "the card is an attraction, or creates attractions"
    end

    it "not: negates cleanly, with no doubled-up connector" do
      assert_explains "not:reprint", "not (the card is a reprint)"
      assert_explains "not:black-bordered", "not (the border is black)"
    end
  end

  context "combining conditions" do
    it "implicit and explicit AND" do
      assert_explains "t:goblin AND mv=2", "the card types include goblin and the mana value is 2"
      assert_explains "t:goblin mv=2", "the card types include goblin and the mana value is 2"
    end

    it "OR" do
      assert_explains "t:goblin OR mv=2", "the card types include goblin or the mana value is 2"
    end

    it "NOT of a single condition" do
      assert_explains "-t:goblin", "not (the card types include goblin)"
    end

    it "NOT combined with another condition doesn't double up the connector" do
      assert_explains "-t:goblin -t:elf", "not (the card types include goblin) and not (the card types include elf)"
    end

    it "NOT of a parenthesized OR group" do
      assert_explains "-(t:goblin OR t:elf)", "not (the card types include goblin or the card types include elf)"
      assert_explains "t:creature -(t:goblin OR t:elf)",
        "the card types include creature and not (the card types include goblin or the card types include elf)"
    end

    it "an OR group nested inside an AND gets parenthesized" do
      assert_explains "c=u (t:goblin OR t:elf)",
        %[the colors is U and (the card types include goblin or the card types include elf)]
    end

    it "an AND group nested inside an OR gets parenthesized" do
      assert_explains "t:goblin OR (mv=2 c:r)",
        "the card types include goblin or (the mana value is 2 and the colors includes at least R)"
    end

    it "two OR groups ANDed together" do
      assert_explains "(e:war or e:m19) (c:r or c:u)",
        %[(the set is "war" or the set is "m19") and (the colors includes at least R or the colors includes at least U)]
    end

    it "nested same-operator groups flatten, since ConditionAnd/ConditionOr flatten and dedup at parse time" do
      assert_explains "(t:goblin OR t:elf) OR (t:dwarf OR t:human)",
        "the card types include goblin or the card types include elf or the card types include dwarf or the card types include human"
    end
  end
end
