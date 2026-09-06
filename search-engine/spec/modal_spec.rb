describe "Modal cards" do
  include_context "db"

  it "is:modal" do
    assert_search_equal "not:modal", "-(is:modal)"
    assert_search_include "is:modal",
      "Cryptic Command",          # plain bulleted modes
      "Fatal Lore",               # an opponent chooses the mode
      "Caught in the Crossfire",  # spree
      "Cloud's Limit Break",      # tiered
      "Season of Weaving",        # pawprint modes
      "Pick Your Poison (CMB1)"   # playtest card counting modes as [1] / [2] / [4]
  end

  # CR 702.172a and 702.183a both say the ability is found on modal spells, but the
  # cards only say so in reminder text, which is not part of the text we search
  it "spree and tiered spells are modal" do
    assert_search_equal "kw:spree", "kw:spree is:modal"
    assert_search_equal "kw:tiered", "kw:tiered is:modal"
  end

  # Canaries for templating we don't handle yet. Each query is a wording that makes
  # a card modal, minus the cards already recognized, so a new printing landing in
  # one of these needs a look at PatchIsModal - not an entry on the exception list.
  #
  # These search `fo:`, not `o:`, because reminder text is where spree and tiered
  # state their modality. The search language has no /i flag - a trailing "i" is
  # parsed as a separate word - but regexps are case-insensitive already.
  it "no modal wording goes unrecognized" do
    # spree's "+" modes, and any future keyword whose reminder text says "(Choose one ..."
    assert_search_results %q[fo:/\n\+ / -is:modal]
    assert_search_results %q[fo:/\(choose one/ -is:modal]
    # pawprint and everything else that counts modes instead of bulleting them
    assert_search_results %q[fo:/worth of modes/ -is:modal]

    # bulleted lists that are not modes: dice tables and menus of tokens
    assert_search_results %q[fo:/\n•/ -is:modal],
      "Celebr-8000",
      "Item Crate",
      "Kharis & The Beholder",
      "Maître Tree"

    # cards that talk about modes without having any
    assert_search_results %q[fo:/\bmodes\b/ -is:modal],
      "Chira, All In",
      "Far Out",
      "Seven of Nine",
      "Your Wish Is My Command"
  end
end
