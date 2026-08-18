describe "Foreign language queries" do
  include_context "db"

  context "German" do
    it "includes German name" do
      assert_search_equal %[foreign:"Abrupter Verfall"], %[de:"Abrupter Verfall"]
      assert_search_equal %q[foreign:/\bvon der\b/], %q[de:/\bvon der\b/]
    end

    it "is anywhere match with de:" do
      assert_search_equal %[de:"Spinner"], %[de:/Spinner/]
    end

    it "is word match with foreign:" do
      assert_search_equal %[foreign:"Spinner"], %[foreign:/\bSpinner\b/ or (Arachnus Spinner)]
    end

    context "Avacyn Restored" do
      include_context "db", "avr"

      it "de" do
        assert_search_results "de:engel",
          "Angel of Glory's Rise",
          "Angel of Jubilation",
          "Angelic Wall",
          "Archangel", # not full word
          "Angel's Mercy", # not full word
          "Angel's Tomb", # not full word
          "Avacyn, Angel of Hope",
          "Emancipation Angel",
          "Entreat the Angels",
          "Restoration Angel"
        assert_search_results %q[de:/\bdes\b/],
          "Alchemist's Refuge",
          "Angel of Glory's Rise",
          "Angel's Mercy",
          "Angel's Tomb",
          "Builder's Blessing",
          "Commander's Authority",
          "Conjurer's Closet",
          "Demonlord of Ashmouth",
          "Druid's Familiar",
          "Herald of War",
          "Midvast Protector",
          "Predator's Gambit",
          "Rush of Blood",
          "Terrifying Presence",
          "Tormentor's Trident"
      end
    end
  end

  context "French" do
    it do
      assert_search_equal %[foreign:"Décomposition abrupte"], %[fr:"Décomposition abrupte"]
    end
    it "is case insensitive" do
      assert_search_equal %[foreign:"Décomposition abrupte"], %[foreign:"décomposition ABRUPTE"]
    end
    it "ignores diacritics" do
      assert_search_equal %[foreign:"Décomposition abrupte"], %[foreign:"Decomposition abrupte"]
    end

    context "Avacyn Restored" do
      include_context "db", "avr"

      it "fr" do
        assert_search_results "fr:Fragments", "Bone Splinters"
        assert_search_results %[fr:"Lumière d'albâtre"], "Bruna, Light of Alabaster"
        assert_search_results %[fr:"lumiere d'albatre"], "Bruna, Light of Alabaster"
      end
    end
  end

  context "Italian" do
    it "includes Italian name" do
      assert_search_equal %[foreign:"Deterioramento Improvviso"], %[it:"Deterioramento Improvviso"]
    end

    context "Avacyn Restored" do
      include_context "db", "avr"

      it "it" do
        assert_search_results "it:clemenza", "Angel's Mercy"
        assert_search_results %q[it:/\bdell\b/],
          "Alchemist's Apprentice",
          "Alchemist's Refuge",
          "Angel of Glory's Rise",
          "Angel's Mercy",
          "Angel's Tomb",
          "Conjurer's Closet",
          "Essence Harvest",
          "Seraph of Dawn",
          "Timberland Guide",
          "Treacherous Pit-Dweller",
          "Vanguard's Shield"
      end
    end
  end

  context "Japanese" do
    it "includes Japanese name" do
      assert_search_equal %[foreign:"血染めの月"], %[jp:"血染めの月"]
    end

    context "Avacyn Restored" do
      include_context "db", "avr"

      it "jp" do
        assert_search_results "jp:ブルーナ", "Bruna, Light of Alabaster"
        assert_search_results %q[jp:/ブルーナ/], "Bruna, Light of Alabaster"
      end
    end
  end

  context "Korean" do
    it "includes Korean name" do
      assert_search_equal %[foreign:"축복받은 신령들"], %[kr:"축복받은 신령들"]
      assert_search_equal %q[foreign:/축복받은/], %q[kr:/축복받은/]
    end

    context "Avacyn Restored" do
      include_context "db", "avr"

      it "kr" do
        assert_search_results "kr:아바신", "Avacyn, Angel of Hope", "Scroll of Avacyn"
        assert_search_results %q[kr:/아바신/], "Avacyn, Angel of Hope", "Scroll of Avacyn"
      end
    end
  end

  context "Portuguese" do
    it "includes Portuguese name" do
      assert_search_equal %[foreign:"Ponte Traiçoeira"], %[pt:"Ponte Traiçoeira"]
    end

    context "Avacyn Restored" do
      include_context "db", "avr"

      it "pt" do
        assert_search_results "pt:estacas", "Bone Splinters"
        assert_search_results %q[pt:/estacas/], "Bone Splinters"
      end
    end
  end

  context "Russian" do
    it "includes Russian name" do
      assert_search_equal %[foreign:"Кровавая луна"], %[ru:"Кровавая луна"]
    end

    context "Avacyn Restored" do
      include_context "db", "avr"

      it "ru" do
        assert_search_results "ru:Ангел",
          "Angel of Glory's Rise",
          "Angel of Jubilation",
          "Avacyn, Angel of Hope",
          "Emancipation Angel",
          "Restoration Angel"
        assert_search_equal "ru:ангел", "ru:Ангел"
        assert_search_equal "ru:АНГЕЛ", "ru:Ангел"
        assert_search_equal %q[ru:/\bАНГЕЛ\b/], "ru:Ангел"
      end
    end
  end

  context "Spanish" do
    it "includes Spanish name" do
      assert_search_equal %[foreign:"Puente engañoso"], %[sp:"Puente engañoso"]
    end

    context "Avacyn Restored" do
      include_context "db", "avr"

      it "sp" do
        assert_search_results "sp:Astillas", "Bone Splinters"
        assert_search_results %q[sp:/astillas/], "Bone Splinters"
      end
    end
  end

  context "Chinese Simplified" do
    it "includes Chinese Simplified name" do
      assert_search_equal %[foreign:"刻拉诺斯的电击"], %[cs:"刻拉诺斯的电击"]
    end

    context "Avacyn Restored" do
      include_context "db", "avr"

      it "cs" do
        assert_search_results "cs:拱翼巨龙", "Archwing Dragon"
        assert_search_results "zhs:拱翼巨龙", "Archwing Dragon"
        assert_search_results "tw:拱翼巨龙"
        assert_search_results "ct:拱翼巨龙"
        assert_search_results "zht:拱翼巨龙"
      end
    end
  end

  context "Chinese Traditional" do
    it "includes Chinese Traditional name" do
      assert_search_equal %[foreign:"刻拉諾斯的電擊"], %[ct:"刻拉諾斯的電擊"]
    end

    context "Avacyn Restored" do
      include_context "db", "avr"

      it "chinese_traditional" do
        assert_search_results "ct:拱翼巨龍", "Archwing Dragon"
        assert_search_results "zht:拱翼巨龍", "Archwing Dragon"
        assert_search_results "tw:拱翼巨龍", "Archwing Dragon"
        assert_search_results "cs:拱翼巨龍"
        assert_search_results "zhs:拱翼巨龍"
      end
    end
  end

  # This test is a bit fragile to reprints
  it "wildcard" do
    # Searching cards, as languages are not attached to printings
    # this data is not always reliable in mtgjson and often lags set releases
    # Quintorius, History Chaser looks like data issue?
    assert_search_equal_cards "t:planeswalker fr:* -sp:* -(Quintorius, History Chaser)", "t:planeswalker e:cmm -alt:-e:cmm"
  end

  # The pattern used to be downcased before it was compiled, on top of the
  # IGNORECASE it is compiled with anyway. That turned \A into \a, \Z into \z,
  # \P{...} into \p{...}, and every other uppercase escape into a different one.
  it "does not mangle uppercase escapes in the pattern" do
    assert_search_equal %q[fr:/\AContresort\z/], %q[fr:/^Contresort$/]
    assert_search_results %q[fr:/\AContresort\Z/], "Counterspell"
    assert_search_differ %q[foreign:/\p{Han}/], %q[foreign:/\P{Han}/]
    assert_search_differ %q[foreign:/\d/], %q[foreign:/\D/]
  end

  it "only matches full words (except CJK and German)" do
    assert_search_differ %q[foreign:/red/], %q[foreign:/\bred\b/]
    assert_search_differ %q[foreign:/电击/], %q[foreign:/\b电击\b/]
    assert_search_equal %q[foreign:red], %q[foreign:/\bred\b/]
    assert_search_equal %q[foreign:电击], %q[foreign:/电击/]
  end

  # It looks like scryfall went for in:* so for compatibility
  it "in:X aliases X:*" do
    assert_search_equal "in:cs", "cs: *"
    assert_search_equal "in:ct", "ct: *"
    assert_search_equal "in:de", "de: *"
    assert_search_equal "in:fr", "fr: *"
    assert_search_equal "in:it", "it: *"
    assert_search_equal "in:jp", "jp: *"
    assert_search_equal "in:kr", "kr: *"
    assert_search_equal "in:pt", "pt: *"
    assert_search_equal "in:ru", "ru: *"
    assert_search_equal "in:sp", "sp: *"
    assert_search_equal "in:tw", "tw: *"
    assert_search_equal "in:zht", "zht: *"
    assert_search_equal "in:zhs", "zhs: *"
  end

  it "is:foreign" do
    assert_search_equal "e:6ed is:foreign", "e:6ed number:/s/"
    assert_search_equal "e:sta is:foreign", "e:sta number>=64"
    assert_search_equal "e:dmu is:foreign", "e:dmu number:369-370"
  end

  # Wizards has retranslated cards over the years, so a card reprinted for long
  # enough has more than one name in a language. Only 765 of 245,000 names, so
  # a card holds its name for a language as a plain string and only these hold
  # an array - which is why everything reading them splats. These are all old
  # cards whose printing history cannot change, so they stay multi-translation.
  context "cards with more than one translation in a language" do
    it "keeps every translation" do
      db.cards["shivan dragon"].foreign_names[:fr].should eq ["Dragon Shîvan", "Dragon shivân"]
      db.cards["shivan dragon"].foreign_names[:pt].should eq ["Dragão de Shiva", "Dragão de Shiv"]
      db.cards["sol ring"].foreign_names[:jp].should eq ["太陽のリング", "太陽の指輪"]
      db.cards["wrath of god"].foreign_names[:sp].should eq ["Ira de Dios", "Ira de Díos"]
      db.cards["serra angel"].foreign_names[:pt].should eq ["Anjo Serra", "Anjo de Serra"]
      db.cards["llanowar elves"].foreign_names[:cs].should eq ["罗堰地精", "罗堰妖精"]
      # Three, one of them a typo Wizards printed and then fixed
      db.cards["elixir of immortality"].foreign_names[:fr].should eq [
        "Elixir d'immortalité", "Exilir d'immortalité", "Élixir d'immortalité",
      ]
    end

    it "finds the card by any of them" do
      assert_search_results %[fr:"Dragon Shîvan"], "Shivan Dragon"
      assert_search_results %[fr:"Dragon shivân"], "Shivan Dragon"
      assert_search_results %[jp:"太陽のリング"], "Sol Ring"
      assert_search_results %[jp:"太陽の指輪"], "Sol Ring"
      assert_search_results %[pt:"Anjo Serra"], "Serra Angel"
      assert_search_results %[pt:"Anjo de Serra"], "Serra Angel"
      assert_search_results %[fr:"Exilir d'immortalité"], "Elixir of Immortality"
      assert_search_results %[fr:"Élixir d'immortalité"], "Elixir of Immortality"
    end

    it "finds the card by any of them with foreign: and regexps" do
      assert_search_results %[foreign:"太陽の指輪"], "Sol Ring"
      assert_search_results %q[fr:/\AExilir d'immortalite\z/], "Elixir of Immortality"
      assert_search_results %q[foreign:/\ADragon shivan\z/], "Shivan Dragon"
    end

    # The common shape, kept distinct from the above on purpose
    it "leaves a card with one translation per language as a plain string" do
      db.cards["counterspell"].foreign_names[:fr].should eq "Contresort"
      db.cards["counterspell"].foreign_names_normalized[:fr].should eq "contresort"
    end
  end
end
