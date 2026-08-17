# is:extra is deliberately absent from the syntax help - it exposes an internal
# flag for debugging format legality, nothing more. See condition_is_extra.rb.
describe "is:extra" do
  include_context "db"

  # Phenome-nom is Unstable's joke spelling of Phenomenon, and the only card
  # where the type doesn't name one of the categories below
  it "is card types no format can play, plus Alchemy rebalances" do
    assert_search_equal "is:extra",
      "t:vanguard or t:plane or t:phenomenon or t:phenome-nom or t:scheme or t:conspiracy or is:alchemy"
  end
end
