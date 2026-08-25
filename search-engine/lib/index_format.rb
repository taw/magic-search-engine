# Vocabularies shared between the indexer, which writes sets.json and
# cards.jsonl, and CardDatabase, which reads them.
#
# Values from these lists are stored in the index as their integer index,
# which is a lot smaller than spelling the string out on every printing.
# These are all closed vocabularies - the indexer raises on anything not
# listed here, so don't use this for anything mtgjson keeps adding to.
#
# All these lists are append-only. Reordering or removing an entry silently
# changes the meaning of every card already in the index.
module IndexFormat
  # For BORDERS and FRAMES the first entry is the default, and is left out of
  # the index entirely.
  RARITIES = %W[basic common uncommon rare mythic special].each(&:freeze).freeze
  BORDERS  = %W[black white silver gold borderless yellow].each(&:freeze).freeze
  FRAMES   = %W[2015 2003 1997 1993 future].each(&:freeze).freeze
  STAMPS   = %W[oval triangle arena acorn circle heart].each(&:freeze).freeze

  # Finishes are not one of those lists: a printing comes in any combination of
  # the three, so "fo" holds their bits added up rather than an index into
  # anything. nonfoil+foil is most of them, so it is the default that is left
  # out of the index entirely. PhysicalCard::FINISHES takes its order and its
  # names from here.
  FINISH_BITS = {nonfoil: 1, foil: 2, etched: 4}.freeze
  DEFAULT_FINISHES = FINISH_BITS[:nonfoil] | FINISH_BITS[:foil]

  # Boolean printing flags are packed into a single string under the "!" key,
  # one character each, instead of a `"key":true,` pair each.
  FLAGS = {
    "arena"            => "a",
    "digital"          => "g",
    "dreamcast"        => "d",
    "fullart"          => "f",
    "nontraditional"   => "n",
    "nontournament"    => "u",
    "oversized"        => "o",
    "shandalar"        => "h",
    "spotlight"        => "s",
    "textless"         => "l",
    "timeshifted"      => "i",
    "token"            => "t",
    "variant_arena"    => "r",
    "variant_foreign"  => "v",
    "variant_misprint" => "m",
  }.freeze

  # These are true for the majority of printings, so the flag marks their
  # absence instead. Always uppercase - a lowercase character is only ever
  # looked up in FLAGS and an uppercase one only here, so "m" (variant misprint
  # is present) and "M" (mtgo is not) mean unrelated things.
  NEGATED_FLAGS = {
    "mtgo"  => "M",
    "paper" => "P",
    "xmage" => "X",
  }.freeze
end
