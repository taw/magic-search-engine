# Due to way mtgjson updates, old templates often stay for a while in db
# Let's make sure to prevent regressions at least
# These numbers decreasing is good. Increasing is bad.
describe "Old templates" do
  include_context "db"

  # Gem Bazaar (Astral Cards)
  # R&D's Secret Lair (Unhinged)
  it do
    assert_count_cards %[o:"mana pool"], 2
  end

  # Chandra, Gremlin Wrangler (silver-border)
  # Comet, Stellar Pup (silver-border)
  # Crovax (avatar)
  # Firesong and Sunspeaker (legitimate)
  # Sarah's Wings (CMB1)
  # Tornellan Protector (Sega Dreamcast Cards)
  # Ertha Jo, Frontier Mentor
  it do
    assert_count_cards %[o:"creature or player"], 7
  end

  it do
    assert_count_cards %[o:"~ can't be countered"], 0
  end

  ### On non-Gatherer cards only
  it do
    assert_count_cards %[o:"his or her"], 0
    assert_count_cards %[o:"he or she"], 1 # Power Struggle
    assert_count_cards %[o:"him or her"], 0
  end

  # Robot Chicken
  # Garruk the Slayer
  it do
    assert_count_cards %[o:"token onto the battlefield"], 2
  end

  it do
    assert_count_cards %[o:"can't be countered by spells or abilities"], 0
  end
end
