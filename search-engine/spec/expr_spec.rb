describe "Expressions Test" do
  include_context "db"

  it "warns about values it cannot parse" do
    db.search("pow>=1.2.3").warnings.should include(%[Unknown value "1.2.3" in "pow>=1.2.3"])
    # cmc is normalized to mv, so that's how the warning echoes it back
    db.search("cmc>=2+2").warnings.should include(%[Unknown value "2+2" in "mv>=2+2"])
    db.search("pow>=xx").warnings.should include(%[Unknown value "xx" in "pow>=xx"])
    # Values which are perfectly fine, just no card matches them
    db.search("pow>=1d4+1").warnings.should be_empty
    db.search("pow>=∞").warnings.should be_empty
    db.search("pow>=*2").warnings.should be_empty
    db.search("tou<=1½").warnings.should be_empty
    db.search("cmc>=2 pow>tou loy>=5 year>=2000 decklimit>=4").warnings.should be_empty
  end

  it "extra_spaces_in_expr" do
    assert_search_equal "cmc>=7", "cmc >= 7"
    assert_search_equal "pow=cmc", "pow = cmc"
    assert_search_equal "tou<3", "tou < 3"
  end

  context "pow / tou / loy" do
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
      assert_search_results "tou<8-*", "Shapeshifter"
      assert_search_results "tou<=8-*", "Shapeshifter"
      assert_search_results "tou<=2-*"
    end

    it "quoting" do
      assert_search_equal %[pow="1+*"], %[pow=1+*]
      assert_search_equal %[tou="1+*"], %[tou=1+*]
      assert_search_equal %[loy="X"], %[loy=X]
    end

    context "Magic 2010" do
      include_context "db", "m10"

      it "pow" do
        assert_search_results "pow=0 c:g", "Birds of Paradise", "Bramble Creeper", "Protean Hydra"
        assert_search_results "pow>=4 c:u", "Air Elemental", "Djinn of Wishes", "Sphinx Ambassador"
        assert_search_results "pow>4 c:u", "Sphinx Ambassador"
        assert_search_results "pow<=4 c:c", "Ornithopter", "Platinum Angel"
        assert_search_results "pow<4 c:c", "Ornithopter"
        assert_search_results "pow=6", "Ball Lightning", "Capricious Efreet", "Craw Wurm"
        assert_search_results "pow<tou c:r", "Dragon Whelp", "Goblin Artillery", "Stone Giant", "Wall of Fire"
        assert_search_results "pow>cmc c:r", "Ball Lightning", "Jackal Familiar"
      end

      it "tou" do
        assert_search_results "tou<=cmc c:c", "Darksteel Colossus", "Platinum Angel"
        assert_search_results "tou>=9", "Darksteel Colossus", "Kalonian Behemoth"
        assert_search_results "tou>9", "Darksteel Colossus"
      end

      it "loyalty" do
        assert_search_results "loyalty=5", "Liliana Vess"
        assert_search_results "loyalty>cmc", "Chandra Nalaar"
        assert_search_results "loyalty<=4", "Ajani Goldmane", "Garruk Wildspeaker", "Jace Beleren"
      end
    end

    context "Kaladesh" do
      include_context "db", "kld"

      it "vehicles" do
        assert_search_results "pow=10", "Demolition Stomper", "Metalwork Colossus"
        assert_search_results "tou=7", "Accomplished Automaton", "Demolition Stomper"
      end
    end

    context "Unsets" do
      include_context "db", "ugl", "unh", "pcel", "hho", "ust", "und", "unf"

      it "half power" do
        "pow=1"  .should exclude_cards "Little Girl"
        "pow>0"  .should include_cards "Little Girl"
        "pow=0.5".should include_cards "Little Girl"
        "pow=½"  .should include_cards "Little Girl"
        "pow<1"  .should include_cards "Little Girl"
        "pow=1"  .should exclude_cards "Little Girl"
        "pow>1"  .should exclude_cards "Little Girl"
        "pow=tou".should include_cards "Little Girl"
        "pow=cmc".should include_cards "Little Girl"
      end

      it "half toughness" do
        "tou=1"  .should exclude_cards "Little Girl"
        "tou>0"  .should include_cards "Little Girl"
        "tou=0.5".should include_cards "Little Girl"
        "tou=½"  .should include_cards "Little Girl"
        "tou<1"  .should include_cards "Little Girl"
        "tou=1"  .should exclude_cards "Little Girl"
        "tou>1"  .should exclude_cards "Little Girl"
      end

      it "infinite power" do
        "pow>30".should return_cards "B.F.M. (Big Furry Monster)",
          "B.F.M. (Big Furry Monster, Right Side)",
          "Infinity Elemental"
        "pow=∞".should return_cards "Infinity Elemental"
        "pow>=∞".should return_cards "Infinity Elemental"
        assert_search_equal "pow<∞", "pow<10000"
        assert_search_equal "pow<=∞", "pow<=10000 or (Infinity Elemental)"
      end

      it "question mark power/toughness" do
        assert_search_results "pow=?", "Shellephant"
        assert_search_equal "pow=?", "pow>=?"
        assert_search_equal "pow=?", "pow<=?"
        assert_search_results "pow>?"
        assert_search_results "pow<?"

        assert_search_results "tou=?", "Shellephant"
        assert_search_equal "tou=?", "tou>=?"
        assert_search_equal "tou=?", "tou<=?"
        assert_search_results "tou>?"
        assert_search_results "tou<?"
      end
    end
  end

  context "pt (power and toughness total)" do
    it "pt" do
      assert_search_equal "pt=4", "(pow=0 tou=4) or (pow=1 tou=3) or (pow=2 tou=2) or (pow=3 tou=1) or (pow=4 tou=0)"
      assert_search_equal "powtou=4", "pt=4"
      assert_search_equal "pt:4", "pt=4"
      assert_search_equal "pt=cmc", "cmc=pt"
      db.search("pt>=4 powtou<=8").warnings.should be_empty
    end

    # pt: is also Portuguese name search, and it stays that way for anything but numbers and such
    it "pt does not break Portuguese search" do
      assert_search_equal "pt:goblin", "pt=goblin"
      # Manoplas de Couro de Goblin, no goblin anywhere in the English name
      assert_search_include "pt:goblin", "Golem-Skin Gauntlets"
      assert_search_exclude "pt:4", "Golem-Skin Gauntlets"
    end

    it "pt of star power and toughness" do
      # A bare * belongs to the Portuguese wildcard, so the star total needs the long name here
      assert_search_equal "powtou=*", "(pow=* tou=*) or (pow=* tou=0) or (pow=0 tou=*)"
      assert_search_equal "pt=*", "in:pt"
      assert_search_equal "pt=1+*", "(pow=* tou=1+*) or (pow=1+* tou=*) or (pow=* tou=1) or (pow=1 tou=*)"
      assert_search_equal "pt=2+*",
        "(pow=1+* tou=1+*) or (pow=* tou=2+*) or (pow=2+* tou=*) or (pow=* tou=2) or (pow=2 tou=*) or (pow=1+* tou=1) or (pow=1 tou=1+*)"
      assert_search_include "pt=1+*", "Tarmogoyf"
      # Star totals are not numbers, so they don't answer numeric questions
      assert_search_exclude "pt>=0", "Tarmogoyf", "Nameless Race"
    end

    it "pt of everything else weird" do
      assert_search_results "pt=∞", "Infinity Elemental"
      assert_search_results "pt=1 pow=½", "Little Girl"
      assert_search_results "pt=-1", "Half-Squirrel, Half-"
      # *², ?, and X have no sensible total, so those cards match no pt query at all
      assert_search_exclude "pt>=0", "S.N.O.T.", "Catch of the Day"
      assert_search_results "pt=x"
      assert_search_results "pt=*2"
    end
  end

  context "mv / cmc" do
    context "Magic 2010" do
      include_context "db", "m10"

      it "even / odd" do
        assert_search_equal "mv:even", "cmc=0 or cmc=2 or cmc=4 or cmc=6 or cmc=8"
        assert_search_equal "mv:odd", "cmc=1 or cmc=3 or cmc=5 or cmc=7 or cmc=11"
        # Every card here has a whole number mana value, so the two partition the set
        assert_search_equal "mv:even", "-mv:odd"
        assert_search_equal "mv:even", "manavalue:even"
        assert_search_equal "mv:odd", "cmc=odd"
        # Parity is not specific to mana value
        assert_search_results "loy:even", "Ajani Goldmane", "Chandra Nalaar"
        assert_search_equal "pow:odd", "pow=1 or pow=3 or pow=5 or pow=7 or pow=9 or pow=11"
        # Darksteel Colossus is 11/11, Nightmare's power is *
        assert_search_include "pow:odd", "Darksteel Colossus"
        assert_search_exclude "pow:odd", "Nightmare"
        assert_search_exclude "pow:even", "Nightmare"
      end

      it "even / odd only compares with =" do
        db.search("mv:even").warnings.should be_empty
        db.search("mv>even").warnings.should include(
          %[Only = is supported for even queries, ignoring > in "mv>even"]
        )
        # It still answers the question it can answer
        assert_search_equal "mv>even", "mv:even"
      end

      it "cmc" do
        assert_search_results "cmc=0",
          "Dragonskull Summit",
          "Drowned Catacomb",
          "Forest",
          "Gargoyle Castle",
          "Glacial Fortress",
          "Island",
          "Mountain",
          "Ornithopter",
          "Plains",
          "Rootbound Crag",
          "Spellbook",
          "Sunpetal Grove",
          "Swamp",
          "Terramorphic Expanse"
        assert_search_results "cmc>=7 c:r", "Bogardan Hellkite", "Warp World"
        assert_search_results "cmc=7 c:u", "Sphinx Ambassador"
      end
    end

    context "Eldritch Moon" do
      include_context "db", "emn"

      it "meld cmc" do
        assert_search_results "is:meld cmc=0", "Hanweir Battlements"
        assert_search_results "is:meld cmc=2", "Graf Rats"
        assert_search_results "is:meld cmc=3", "Hanweir Garrison", "Hanweir, the Writhing Township"
        assert_search_results "is:meld cmc=4", "Gisela, the Broken Blade"
        assert_search_results "is:meld cmc=5", "Midnight Scavengers"
        assert_search_results "is:meld cmc=7", "Bruna, the Fading Light", "Chittering Host"
        assert_search_results "is:meld cmc=11", "Brisela, Voice of Nightmares"
      end

      it "dfc cmc" do
        # back face has same mana value as front face, it doesn't get 0
        assert_search_results "layout:transform cmc=0"
        assert_search_results "layout:transform cmc=1",
          "Kessig Prowler", "Sinuous Predator"
        assert_search_results "layout:transform cmc=2",
          "Curious Homunculus", "It That Rides as One", "Lone Rider",
          "Ulvenwald Abomination", "Ulvenwald Captive", "Voracious Reader"
        assert_search_results "layout:transform cmc=3",
          "Aurora of Emrakul", "Conduit of Emrakul", "Conduit of Storms",
          "Cryptolith Fragment", "Extricator of Flesh", "Extricator of Sin",
          "Grisly Anglerfish", "Grizzled Angler", "Howling Chorus", "Shrill Howler"
        assert_search_results "layout:transform cmc=4",
          "Erupting Dreadwolf", "Fibrous Entangler",
          "Smoldering Werewolf", "Tangleclaw Werewolf"
        assert_search_results "layout:transform cmc=5",
          "Abolisher of Bloodlines", "Docent of Perfection", "Dronepack Kindred",
          "Final Iteration", "Ulrich of the Krallenhorde", "Ulrich, Uncontested Alpha",
          "Vildin-Pack Outcast", "Voldaren Pariah"
      end

      it "dfc cmc is same on both sides" do
        (1..5).each do |cmc|
          assert_search_equal "layout:transform cmc=#{cmc}", "layout:transform other:cmc=#{cmc}"
        end
      end

      it "cmc is an alias of mv" do
        assert_search_equal "layout:transform mv=5", "layout:transform cmc=5"
      end
    end

    context "Ixalan" do
      include_context "db", "xln"

      it "DFC cmc" do
        assert_search_equal "t:land cmc>0", "is:dfc t:land"
      end
    end

    context "Zendikar Rising" do
      include_context "db", "znr"

      it "Modal DFC cmc" do
        assert_search_results "t:land cmc>0"
        assert_search_results "is:modaldfc cmc=7",
          "Emeria's Call",
          "Sea Gate Restoration",
          "Turntimber Symbiosis"
      end
    end

    context "Unsets" do
      include_context "db", "ugl", "unh", "pcel", "hho", "ust", "und", "unf"

      it "half cmc" do
        "cmc=1"  .should exclude_cards "Little Girl"
        "cmc>0"  .should include_cards "Little Girl"
        "cmc=0.5".should include_cards "Little Girl"
        "cmc=½"  .should include_cards "Little Girl"
        "cmc<1"  .should include_cards "Little Girl"
        "cmc=1"  .should exclude_cards "Little Girl"
        "cmc>1"  .should exclude_cards "Little Girl"
      end

      it "half mv has no parity" do
        "mv:even".should exclude_cards "Little Girl"
        "mv:odd" .should exclude_cards "Little Girl"
      end

      it "half mv" do
        "mv=1"  .should exclude_cards "Little Girl"
        "mv>0"  .should include_cards "Little Girl"
        "mv=0.5".should include_cards "Little Girl"
        "mv=½"  .should include_cards "Little Girl"
        "mv<1"  .should include_cards "Little Girl"
        "mv=1"  .should exclude_cards "Little Girl"
        "mv>1"  .should exclude_cards "Little Girl"
      end
    end
  end

  it "year" do
    "t:planeswalker year = 2010".should have_count_printings 16
    "t:planeswalker year < 2013".should have_count_printings 72
    "t:planeswalker year > 2014".should equal_search "t:planeswalker year >= 2015"
  end

  it "sets" do
    assert_search_equal "sets=1 or sets=2 or sets=3", "sets<=3"
    assert_search_equal "sets=1 or sets=2 or sets=3", "sets<4"
    assert_search_equal "sets>7", "sets>=8"
  end

  it "prints" do
    assert_search_equal "prints=1 or prints=2 or prints=3", "prints<=3"
    assert_search_equal "prints=1 or prints=2 or prints=3", "prints<4"
    assert_search_equal "prints>7", "prints>=8"
  end

  it "papersets" do
    assert_search_equal "papersets=0 or papersets=1 or papersets=2 or papersets=3", "papersets<=3"
    assert_search_equal "papersets=0 or papersets=1 or papersets=2 or papersets=3", "papersets<4"
    assert_search_equal "papersets>7", "papersets>=8"
  end

  it "paperprints" do
    assert_search_equal "paperprints=0 or paperprints=1 or paperprints=2 or paperprints=3", "paperprints<=3"
    assert_search_equal "paperprints=0 or paperprints=1 or paperprints=2 or paperprints=3", "paperprints<4"
    assert_search_equal "paperprints>7", "paperprints>=8"
  end

  it "prints and sets expressions" do
    card = db.cards["giant spider"]
    assert_search_include "prints=#{card.printings.size}", "Giant Spider"
    assert_search_include "paperprints=#{card.printings.count(&:paper?)}", "Giant Spider"
    assert_search_include "sets=#{card.printings.map(&:set).uniq.size}", "Giant Spider"
    assert_search_include "papersets=#{card.printings.select(&:paper?).map(&:set).uniq.size}", "Giant Spider"
  end

  it "defense" do
    assert_search_results "defense=7 e:mom",
      "Invasion of Alara",
      "Invasion of Arcavios"
    assert_search_results "defense<4 e:mom",
      "Invasion of Gobakhan",
      "Invasion of Zendikar"
    assert_search_equal "defense=7", "defence=7"
  end

  it "hand" do
    assert_search_results "hand=-3",
      "Multani"
    assert_search_equal "hand=+1", "hand=1"
  end

  it "life" do
    assert_search_results "life<-6",
      "Ashnod",
      "Takara",
      "Maro Avatar" # Magic Online Avatars
    assert_search_equal "life=+1", "life=1"
    assert_search_equal "life=+0", "life=0"
    assert_search_equal "life=-0", "life=0"
  end
end
