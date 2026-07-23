# Vocabularies shared between the indexer, which writes index.json,
# and CardDatabase, which reads it.
#
# Values from these lists are stored in the index as their integer index,
# which is a lot smaller than spelling the string out on every printing.
# These are all closed vocabularies - the indexer raises on anything not
# listed here, so don't use this for anything mtgjson keeps adding to.
#
# All these lists are append-only. Reordering or removing an entry silently
# changes the meaning of every card already in the index.
module IndexFormat
  # For BORDERS, FRAMES and FOILINGS the first entry is the default,
  # and is left out of the index entirely.
  RARITIES = %W[basic common uncommon rare mythic special].each(&:freeze).freeze
  BORDERS  = %W[black white silver gold borderless yellow].each(&:freeze).freeze
  FRAMES   = %W[2015 2003 1997 1993 future].each(&:freeze).freeze
  FOILINGS = %W[both nonfoil foilonly].each(&:freeze).freeze
  STAMPS   = %W[oval triangle arena acorn circle heart].each(&:freeze).freeze

  FOILING_SYMBOLS = FOILINGS.map(&:to_sym).freeze

  # Boolean printing flags are packed into a single string under the "!" key,
  # one character each, instead of a `"key":true,` pair each.
  FLAGS = {
    "arena"            => "a",
    "digital"          => "g",
    "dreamcast"        => "d",
    "etched"           => "e",
    "fullart"          => "f",
    "nontournament"    => "n",
    "oversized"        => "o",
    "shandalar"        => "h",
    "spotlight"        => "s",
    "textless"         => "l",
    "timeshifted"      => "i",
    "token"            => "t",
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
