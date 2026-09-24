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

  it "mana= (mana cost, symbols always bracketed for the frontend's mana-icon renderer)" do
    assert_explains "mana=0", "the mana cost is {0}"
    assert_explains "mana={}", "the card has no mana cost"
    assert_explains "mana!={}", "the card has a mana cost"
    assert_explains "mana<=4", "the mana cost is at most {4}"
    assert_explains "mana=3uu", "the mana cost is {3}{u}{u}"
    assert_explains "mana>={b/g}", "the mana cost is at least {bg}"
    assert_explains "mana!=2gr", "the mana cost isn't {2}{g}{r}"
  end

  it "mana= with variable symbols (m/n/o/h) - wrapped unformatted, no icon for those" do
    assert_explains "mana=m", "the mana cost is {m}"
    assert_explains "mana>mm", "the mana cost is more than {m}{m}"
    assert_explains "mana={m}{n}", "the mana cost is {m}{n}"
    assert_explains "mana=hh", "the mana cost is {h}{h}"
  end

  # @query_mana keys are sorted alphabetically internally (order doesn't matter for
  # matching), but the frontend's mana-icon whitelist recognizes a fixed, real-card
  # order per pair - {W/B} not {B/W}, {R/W} not {W/R}, {G/U} not {U/G} - so display
  # has to map back to that, or the "icon" is just literal unrendered text.
  it "canonicalizes hybrid/Phyrexian symbol order to match the frontend's whitelist, not alphabetical order" do
    assert_explains "mana>={w/b}", "the mana cost is at least {wb}"
    assert_explains "mana>={r/w}", "the mana cost is at least {rw}"
    assert_explains "mana>={g/u}", "the mana cost is at least {gu}"
    assert_explains "mana>={c/b}", "the mana cost is at least {cb}"
    assert_explains "mana>={r/p}", "the mana cost is at least {rp}"
    assert_explains "mana>={w/u/p}", "the mana cost is at least {wup}"
    assert_explains "devotion>={w/b}{w/b}{w/b}", "the devotion to {wb} is at least 3"
  end

  it "devotion= (devotion to a color/hybrid symbol, a plain count)" do
    assert_explains "devotion=bbb", "the devotion to {b} is 3"
    assert_explains "devotion>=ww", "the devotion to {w} is at least 2"
    assert_explains "devotion<uuu", "the devotion to {u} is less than 3"
    assert_explains "devotion={u/b}{u/b}", "the devotion to {ub} is 2"
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

  it "legal:/restricted:/banned:/f: (format lookups)" do
    assert_explains "legal:standard", "the card is legal in Standard"
    assert_explains "restricted:vintage", "the card is restricted in Vintage"
    assert_explains "banned:pauper", "the card is banned in Pauper"
    assert_explains "f:commander", "the card is legal or restricted in Commander"
    assert_explains "f:edh", "the card is legal or restricted in Commander"
    assert_explains "banned:*", "the card is banned in any format"
    assert_explains "banned:nonsense", %[the card is banned in "nonsense"]
  end

  it "b: (block)" do
    assert_explains "b:zendikar", %[the block is "zendikar"]
    assert_explains "b:isd,soi", %[the block is "isd" or "soi"]
  end

  it "deck: (preconstructed deck)" do
    assert_explains %[deck:"Feline Ferocity"], %[the card is available in deck "Feline Ferocity"]
  end

  it "booster:/booster-foil:/booster-nonfoil:" do
    assert_explains "booster:nph", %[the card is available in booster "nph"]
    assert_explains "booster-foil:akh-draft", %[the card is available in foil booster "akh-draft"]
    assert_explains "booster:*", %[the card is available in booster "*"]
  end

  it "cast: (castable with only these mana sources)" do
    assert_explains "cast:r", "the card is castable using only {r} mana"
    assert_explains "cast:cu", "the card is castable using only {c}{u} mana"
  end

  it "subset: (Secret Lair Drop subset)" do
    assert_explains %[subset:"Happy Little Gathering"], %[the subset is "happy little gathering"]
  end

  it "bare word / quoted phrase (name search)" do
    assert_explains "channel", %[the name includes "channel"]
    assert_explains %["sword of"], %[the name includes "sword of"]
    assert_explains %[-"sword of"], %[the name doesn't include "sword of"]
  end

  it "!name (exact name)" do
    assert_explains "!channel", %[the name is exactly "channel"]
    assert_explains "!Alive // Well", %[the card has parts named exactly "Alive" and "Well"]
  end

  it "name=/name>/name< (name comparison)" do
    assert_explains %[name="channel"], %[the name is exactly "channel"]
    assert_explains %[name>"Boros Guildgate" name<"Dimir Guildgate"],
      %[the name is alphabetically after "boros guildgate" and the name is alphabetically before "dimir guildgate"]
    assert_explains %[-name>=bob], %[the name is alphabetically before "bob"]
  end

  it "sheet:" do
    assert_explains "sheet:hml/U", %[the card appears on print sheet "hml/U"]
    assert_explains "sheet:hml/U3", %[the card appears on print sheet "hml/U" 3 times]
    assert_explains "sheet:C1", %[the card appears on print sheet "C" once]
    assert_explains "-sheet:*", %[the card doesn't appear on any print sheet]
  end

  it "// (multipart) and part:/other:" do
    assert_explains "mv=2 // mv=3",
      "the card has a part where the mana value is 2, and another part where the mana value is 3"
    assert_explains "t:creature //",
      "the card has a part where the card types include creature, and another part"
    assert_explains "t:land mv=0 // c:r or c:g",
      "the card has a part where (the card types include land and the mana value is 0), and another part where (the colors includes at least R or the colors includes at least G)"
    assert_explains "a // b // c",
      %[the card has a part where the name includes "a", and another part where the name includes "b", and another part where the name includes "c"]
    assert_explains "-(mv=2 // mv=3)",
      "not (the card has a part where the mana value is 2, and another part where the mana value is 3)"
    assert_explains "mv=2 other:c:w",
      "the mana value is 2 and the card has another part where the colors includes at least W"
    assert_explains "mv=2 -other:c:w",
      "the mana value is 2 and the card doesn't have another part where the colors includes at least W"
  end

  it "related:" do
    assert_explains "related:Arrest", %[the card is related to a card matching (the name includes "arrest")]
    assert_explains "-related:t:artifact", "the card isn't related to a card matching (the card types include artifact)"
  end

  it "prints>=N: (count of matching printings)" do
    assert_explains "prints>=2:is:foil", "the number of printings matching (the card has a foil version) is at least 2"
    assert_explains "prints>=2:(e:mh3 -r:c)",
      %[the number of printings matching (the set is "mh3" and the rarity isn't common) is at least 2]
    assert_explains "-prints>=2:e:mh3", %[the number of printings matching (the set is "mh3") is less than 2]
  end

  it "alt:" do
    assert_explains "alt:e:m11", %[the card has a printing matching (the set is "m11")]
    assert_explains "-alt:e:m11", %[the card doesn't have a printing matching (the set is "m11")]
  end

  it "print=/firstprint=/lastprint= (dates)" do
    assert_explains "print>ktk", %[the date of printing is after "ktk"]
    assert_explains %[print="29 September 2012"], %[the date of printing is "29 September 2012"]
    assert_explains "firstprint=m10", %[the date of first printing is "m10"]
    assert_explains "lastprint<=lw", %[the date of last printing is on or before "lw"]
    assert_explains "print>now", "the date of printing is after today"
    assert_explains "-firstprint<ktk", %[the date of first printing is on or after "ktk"]
  end

  it "time:" do
    assert_explains "time:rtr f:standard",
      %[the card is legal or restricted in Standard as of "rtr" and the date of printing is on or before "rtr"]
    assert_explains %[time:"1 march 2009" banned:commander],
      %[the card is banned in Commander as of "2009.3.1" and the date of printing is on or before "2009.3.1"]
    assert_explains "time:m10 firstprint>=m10",
      %[the date of first printing is on or after "m10" as of "m10" and the date of printing is on or before "m10"]
  end

  it "produces=" do
    assert_explains "produces=uw", "the mana produced is {w}{u}"
    assert_explains "produces>=cw", "the mana produced includes at least {w}{c}"
    assert_explains "-produces>=b", "the mana produced doesn't include {b}"
    assert_explains "produces=", "the card doesn't produce mana"
  end

  it "number: ranges" do
    assert_explains "number:10-20,100-200", "the collector number is between 10 and 20 or between 100 and 200"
    assert_explains "number:1-set", "the collector number is between 1 and the set's base size"
    assert_explains "-number:5,7a-9", "the collector number isn't 5 or between 7a and 9"
  end

  it "new: (first printing with a given property)" do
    assert_explains "new:artist", "the card was printed with a new artist"
    assert_explains "new:rarity", "the card was printed at a new rarity"
    assert_explains "new:foil", "the card was first printed in foil"
    assert_explains "new:game", "the card was first added to a new game"
    assert_explains "new:illustrator", "the card was printed with a new artist"
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

    it "not: negates in place, with natural phrasing" do
      assert_explains "not:reprint", "the card is not a reprint"
      assert_explains "not:black-bordered", "the border isn't black"
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

    it "NOT of a single condition negates in place, not wrapped in \"not (...)\"" do
      assert_explains "-t:goblin", "the card types don't include goblin"
    end

    it "NOT combined with another condition doesn't double up the connector" do
      assert_explains "-t:goblin -t:elf", "the card types don't include goblin and the card types don't include elf"
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

  # A single (non-compound) condition negates in place with natural phrasing,
  # instead of being wrapped in "not (...)" - so "-c=w" reads "the colors isn't W",
  # not "not (the colors is W)". Only AND/OR/NOT groups still get the "not (...)" wrap.
  context "negation of a single condition" do
    it "reads as a natural negated clause, not \"not (...)\"" do
      assert_explains "-c=w", "the colors isn't W"
      assert_explains "-c>=gr", "the colors doesn't include RG"
      assert_explains "-t=creature", "the card types aren't exactly creature"
      assert_explains "-t:goblin", "the card types don't include goblin"
      assert_explains "-mv=3", "the mana value isn't 3"
      assert_explains "-r:common", "the rarity isn't common"
      assert_explains "-o:delve", %[the Oracle text doesn't include "delve"]
      assert_explains "-o:/dragon/", "the Oracle text doesn't match the regex `/dragon/`"
      assert_explains "-e:fra", %[the set is not "fra"]
      assert_explains "-number:117", "the collector number isn't 117"
      assert_explains "-is:vertical", "the card is a Plane, Phenomenon, or Battle"
      assert_explains "not:arena", "the card is not available on Arena"
      assert_explains "-legal:standard", "the card is not legal in Standard"
      assert_explains "-b:isd", %[the block is not "isd"]
      assert_explains %[-deck:"Feline Ferocity"], %[the card isn't available in deck "Feline Ferocity"]
      assert_explains "-booster:nph", %[the card isn't available in booster "nph"]
      assert_explains "-cast:r", "the card isn't castable using only {r} mana"
      assert_explains "-new:artist", "the card was not printed with a new artist"
    end

    it "flips comparison operators to their natural complement for totally-ordered fields" do
      assert_explains "-mv>=3", "the mana value is less than 3"
      assert_explains "-mv:even", "the mana value is odd"
      assert_explains "-r>=rare", "the rarity is more common than rare"
    end

    it "doesn't flip comparison operators for colors/types/mana cost, since those are sets, not a total order" do
      # not (colors >= RG) isn't "colors < RG" - a disjoint color like B is neither
      assert_explains "-c>=gr", "the colors doesn't include RG"
      assert_explains %[-t>="land forest"], "the card types don't include land and forest"
      assert_explains "-mana>=2r", "the mana cost isn't at least {2}{r}"
    end

    it "does flip the operator for devotion, since devotion to one color is a plain integer count" do
      assert_explains "-devotion>=ww", "the devotion to {w} is less than 2"
    end

    it "a compound (AND/OR) child still gets wrapped in \"not (...)\", since De Morgan's law isn't attempted" do
      assert_explains "-(t:goblin OR t:elf)", "not (the card types include goblin or the card types include elf)"
      assert_explains "t:creature -(t:goblin OR t:elf)",
        "the card types include creature and not (the card types include goblin or the card types include elf)"
    end
  end
end
