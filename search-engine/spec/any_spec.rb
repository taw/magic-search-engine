# This is just a start of what any: is supposed to do
describe "Any queries" do
  include_context "db"

  context "card name" do
    it do
      assert_search_results %[any:"Abrupt Decay"], "Abrupt Decay"
    end
    it "is case insensitive" do
      assert_search_equal %[any:"ABRUPT decay"], %[any:"Abrupt Decay"]
    end
  end

  it "includes German name" do
    assert_search_equal %[any:"Abrupter Verfall"], %[de:"Abrupter Verfall"]
  end

  context "French name" do
    it do
      assert_search_equal %[any:"Décomposition abrupte"], %[fr:"Décomposition abrupte"]
    end
    it "is case insensitive" do
      assert_search_equal %[any:"Décomposition abrupte"], %[any:"décomposition ABRUPTE"]
    end
    it "ignores diacritics" do
      assert_search_equal %[any:"Décomposition abrupte"], %[any:"Decomposition abrupte"]
    end
  end

  it "includes Italian name" do
    assert_search_equal %[any:"Deterioramento Improvviso"], %[it:"Deterioramento Improvviso"]
  end

  it "includes Japanese name" do
    assert_search_equal %[any:"血染めの月"], %[jp:"血染めの月"]
  end

  it "includes Russian name" do
    assert_search_equal %[any:"Кровавая луна"], %[ru:"Кровавая луна"]
  end

  it "includes Spanish name" do
    assert_search_equal %[any:"Puente engañoso"], %[sp:"Puente engañoso"]
  end

  it "includes Portuguese name" do
    assert_search_equal %[any:"Ponte Traiçoeira"], %[pt:"Ponte Traiçoeira"]
  end

  it "includes Korean name" do
    assert_search_equal %[any:"축복받은 신령들"], %[kr:"축복받은 신령들"]
  end

  it "includes Chinese Traditional name" do
    assert_search_equal %[any:"刻拉諾斯的電擊"], %[ct:"刻拉諾斯的電擊"]
  end

  it "includes Chinese Simplified name" do
    assert_search_equal %[any:"刻拉诺斯的电击"], %[cs:"刻拉诺斯的电击"]
  end

  context "artist" do
    it do
      assert_search_equal %[any:"Wayne England"], %[a:"Wayne England"]
    end
    it "is case insensitive" do
      assert_search_equal %[any:"Wayne England"], %[any:"WAYNE england"]
    end
  end

  context "flavor text" do
    it do
      assert_search_equal %[any:"Jaya Ballard"], %[ft:"Jaya Ballard" OR ("Jaya Ballard")]
    end
    it "is case insensitive" do
      assert_search_equal %[any:"Jaya Ballard"], %[any:"JAYA ballard"]
    end
  end

  context "Oracle text" do
    it do
      assert_search_equal %[any:"win the game"], %[o:"win the game" or ft:"win the game"]
    end
    it "is case insensitive" do
      assert_search_equal %[any:"win the game"], %[any:"Win THE gaME"]
    end
  end

  context "Typeline" do
    it do
      assert_search_equal %[any:"legendary goblin"], %[t:"legendary goblin"]
    end
    it "is case insensitive" do
      assert_search_equal %[any:"legendary goblin"], %[any:"Legendary GOBLIN"]
    end
  end

  context "rarity" do
    # These words conflict a good deal
    # Rare-B-Gone Oracle text mentions "mythic rare"
    it do
      assert_search_equal %[any:"mythic"], %[r:"mythic" or ft:"mythic" or o:"mythic" or "Mythic Proportions"]
    end
    it "aliases" do
      assert_search_equal %[any:"mythic rare"], %[r:"mythic" or o:"mythic rare"]
    end
    it "is case insensitive" do
      assert_search_equal %[any:"UNCOMMON"], %[any:"uncommon"]
    end
  end

  context "color" do
    # A lot of mentions, so let's just get one set and test it there
    it "white" do
      assert_search_equal "e:rtr any:white", "e:rtr (c>=w or o:white)"
    end
    it "blue" do
      assert_search_equal "e:rtr any:blue", "e:rtr (c>=u or o:blue)"
    end
    it "black" do
      assert_search_equal "e:rtr any:black", "e:rtr (c>=b or o:black)"
    end
    it "red" do
      assert_search_equal "e:rtr any:red", "e:rtr (red or c>=r or o:red or foreign:red)"
    end
    it "green" do
      assert_search_equal "e:rtr any:green", "e:rtr (c>=g or o:green)"
    end
    it "colorless" do
      assert_search_equal "e:rtr any:colorless", "e:rtr (c=c or o:colorless)"
    end
  end

  # TODO: maybe do weird ones like Tarmogoyf's */1+* too
  context "p/t" do
    it do
      assert_search_equal %[any:"2/4" any:spider], "pow=2 tou=4 t:spider"
      assert_search_equal %[any:"-1/3"], "pow=-1 tou=3"
      # This is very problematic as -1/-1 is very common in Oracle text
      assert_search_equal %[any:"-1/-1"], %[(pow=-1 tou=-1) or o:"-1/-1"]
    end
  end

  context "is:" do
    it "augment" do
      assert_search_equal "any:augment", "is:augment or o:augment or ft:augment or (augment) or foreign:augment"
    end

    it "nicknames" do
      assert_search_equal "any:battleland", "is:battleland"
      assert_search_equal "any:bounceland", "is:bounceland"
      assert_search_equal "any:canland", "is:canland"
      assert_search_equal "any:canopyland", "is:canopyland"
      assert_search_equal "any:checkland", "is:checkland"
      assert_search_equal "any:creatureland", "is:creatureland"
      assert_search_equal "any:dual", "is:dual or (dual) or ft:dual"
      assert_search_equal "any:fastland", "is:fastland"
      assert_search_equal "any:fetchland", "is:fetchland"
      assert_search_equal "any:filterland", "is:filterland"
      assert_search_equal "any:gainland", "is:gainland"
      assert_search_equal "any:guildgate", "is:guildgate or ft:guildgate"
      assert_search_equal "any:karoo", "is:karoo or (Karoo Meerkat)"
      assert_search_equal "any:keywordsoup", "is:keywordsoup"
      assert_search_equal "any:manland", "is:manland"
      assert_search_equal "any:painland", "is:painland"
      assert_search_equal "any:scryland", "is:scryland"
      assert_search_equal "any:shadowland", "is:shadowland"
      assert_search_equal "any:shockland", "is:shockland"
      assert_search_equal "any:storageland", "is:storageland"
      assert_search_equal "any:tangoland", "is:tangoland"
      assert_search_equal "any:triland", "is:triland"
    end

    it "commander" do
      assert_search_equal "any:commander", "is:commander or ft:commander or o:commander or (commander) or foreign:commander"
    end

    it "digital" do
      assert_search_equal "any:digital", "is:digital or foreign:digital"
    end

    it "funny" do
      assert_search_equal "any:funny", "is:funny or ft:funny"
    end

    it "multipart" do
      assert_search_equal "any:multipart", "is:multipart"
    end

    it "permanent" do
      assert_search_equal "any:permanent", "is:permanent or o:permanent or ft:permanent or foreign:permanent"
    end

    it "primary" do
      assert_search_equal "any:primary", "is:primary"
    end

    it "secondary" do
      assert_search_equal "any:secondary", "is:secondary"
    end

    it "front" do
      assert_search_equal "any:front", "is:front or ft:front"
    end

    it "back" do
      assert_search_equal "any:back", "is:back or o:back or ft:back or (back)"
    end

    it "booster" do
      assert_search_equal "any:booster", "is:booster or o:booster or (Blaster Morale Booster)"
    end

    it "promo" do
      assert_search_equal "any:promo", "is:promo or foreign:promo or (Battlefield Promotion) or o:promo"
    end

    it "reprint" do
      assert_search_equal "any:reprint", "is:reprint"
    end

    it "reserved" do
      assert_search_equal "any:reserved", "is:reserved or ft:reserved"
    end

    it "spell" do
      assert_search_equal "any:spell", "is:spell or o:spell"
    end

    it "timeshifted" do
      assert_search_equal "any:timeshifted", "is:timeshifted"
    end

    it "unique" do
      assert_search_equal "any:unique", "is:unique or ft:unique or o:unique"
    end

    it "vanilla" do
      assert_search_equal "any:vanilla", "is:vanilla or ft:vanilla"
    end

    it "draft" do
      # 4 cards with draft in name
      assert_search_equal "any:draft", "is:draft or draft or (o:draft e:ymid,yneo,ysnc,hbg,ydmu)"
    end
  end
end
