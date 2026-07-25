# Examples from https://scryfall.com/docs/syntax
# and how they work on mtg.wtf
#
# This spec is not really maintained, and parts should probably be moved around
describe "Scryfall" do
  include_context "db"

  it "scryfall bug cmc" do
    # meld cmc is sum of part cmcs
    "c:c t:creature cmc=0".should exclude_cards("Chittering Host")
    # flip cmc equals other part, weirdly it only affect some cards, not all
    "ravager cmc=0".should return_no_cards # "Ravager of the Fells"
  end

  it "red creatures with cmc 2 or less" do
    # scryfall currently failing due to cmc bugs
    assert_search_exclude "c:r t:creature cmc<=2",
      "Ravager of the Fells"
  end

  it "blue cmc 5" do
    # scryfall cmc errors again
    assert_search_include "c:u cmc=5",
      "Ghastly Haunting",
      "Soul Seizer"
  end
end
