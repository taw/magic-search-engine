# Due to way mtgjson updates, old templates often stay for a while in db
# Let's make sure to prevent regressions at least
# These numbers decreasing is good. Increasing is bad.
describe "Old templates" do
  include_context "db"

  it do
    assert_count_cards %Q[o:"mana pool"], 1
  end

  # Sarah's Wings (CMB1)
  it do
    # "Firesong and Sunspeaker" is an exception
    assert_count_cards %Q[o:"creature or player"], 3
  end

  it do
    assert_count_cards %Q[o:"~ can't be countered"], 1
  end

  ### On non-Gatherer cards only
  it do
    assert_count_cards %Q[o:"his or her"], 0
    assert_count_cards %Q[o:"he or she"], 0
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
