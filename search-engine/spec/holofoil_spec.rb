describe "is:holofoil" do
  include_context "db"

  def printing(set_code, number)
    db.printings.find{|cp| cp.set_code == set_code and cp.number == number } or
      raise "No #{set_code}/#{number} printing in the database"
  end

  let(:holofoil) { search_printings("++ is:holofoil").to_set }

  it "matches oval, circle and heart stamps at any rarity" do
    holofoil.should include(
      printing("m15", "1"),   # Ajani Steadfast, where the oval started
      printing("dmu", "432"), # Cut Down, promo pack uncommon
      printing("mid", "388"), # Consider, promo pack common
      printing("cmr", "659"), # Abrade, extended art uncommon
      printing("unf", "239"), # Forest, borderless basic
      printing("ust", "216"), # Forest, full art basic
      printing("ss1", "2"),   # Blue Elemental Blast, Signature Spellbook circle
      printing("ptg", "1a"),  # Nightmare Moon, Ponies heart
    )
  end

  it "matches the Universes Beyond triangle and the acorn only above uncommon" do
    holofoil.should include(
      printing("ltr", "191"), # Aragorn, Company Leader, gold triangle
      printing("unf", "351"), # Animate Graveyard, embossed acorn
    )
    holofoil.should_not include(
      printing("ltr", "39"),  # Arwen's Gift, flat silver triangle
      printing("unf", "383"), # Aardwolf's Advantage, acorn printed on the card
    )
  end

  it "does not match printings with no stamp" do
    holofoil.should_not include(
      printing("cmb1", "86"), # A Good Thing, playtest card
      printing("brr", "1"),   # Adaptive Automaton, retro frame
      printing("ust", "171"), # Bee-Bee Gun, rare contraption
      printing("pss2", "5"),  # Forest, promo basic mtgjson calls rare
      printing("ktk", "106y"),# Crater's Claws, Ugin's Fate promo
    )
  end

  it "does not match digital printings or back faces" do
    holofoil.should_not include(
      printing("ymid", "12"),   # Absorb Energy, Alchemy card with the Arena "A"
      printing("prm", "62501"), # Abbot of Keral Keep, MTGO drawing the paper sticker
      printing("mid", "17b"),   # Angelic Enforcer, back face of a stamped card
    )
  end

  it "is exactly the stamps the printing physically carries" do
    assert_search_equal "++ is:holofoil",
      "++ game:paper -is:back (stamp:oval or stamp:circle or stamp:heart or ((stamp:triangle or stamp:acorn) r>=rare))"
  end
end
