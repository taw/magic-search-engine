# Due to way mtgjson updates, old templates often stay for a while in db
# Let's make sure to prevent regressions at least
# These numbers decreasing is good. Increasing is bad.
describe "Old templates" do
  include_context "db"

  # Gem Bazaar (Astral Cards)
  # R&D's Secret Lair (Unhinged)
  it do
    assert_count_cards %Q[o:"mana pool"], 2
  end

  # Chandra, Gremlin Wrangler (silver-border)
  # Crovax (avatar)
  # Firesong and Sunspeaker (legitimate)
  # Sarah's Wings (CMB1)
  # Tornellan Protector (Sega Dreamcast Cards)
  it do
    assert_count_cards %Q[o:"creature or player"], 5
  end

  it do
    assert_count_cards %Q[o:"~ can't be countered"], 1 # Allosaurus Shepherd
  end

  ### On non-Gatherer cards only
  it do
    assert_count_cards %Q[o:"his or her"], 0
    assert_count_cards %Q[o:"he or she"], 1 # Power Struggle
    assert_count_cards %Q[o:"him or her"], 0
  end

  # Robot Chicken
  # Garruk the Slayer
  it do
    assert_count_cards %Q[o:"token onto the battlefield"], 2
  end

  it do
    assert_count_cards %Q[o:"can't be countered by spells or abilities"], 0
  end
end
