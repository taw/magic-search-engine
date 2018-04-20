# Due to way mtgjson updates, old templates often stay for a while in db
# Let's make sure to prevent regressions at least
# These numbers decreasing is good. Increasing is bad.
describe "Old templates" do
  include_context "db"

  # Migration not complete yet
  it do 
    assert_count_results %Q[o:"his or her"], 53
    assert_count_results %Q[o:"he or she"], 18
    assert_count_results %Q[o:"him or her"], 3
  end

  it do
    assert_count_results %Q[o:"mana pool"], 51
  end

  it do
    assert_count_results %Q[o:"creature or player"], 26
  end

  it do
    assert_count_results %Q[o:"~ can't be countered"], 2
  end

  # Robot Chicken is not Gatherer card
  it do
    assert_count_results %Q[o:"token onto the battlefield"], 1
  end

  # Recently fixed
  it do
    assert_count_results "t:planeswalker -t:legendary", 0
  end

  it do
    assert_count_results %Q[o:"can't be countered by spells or abilities"], 0
  end
end
