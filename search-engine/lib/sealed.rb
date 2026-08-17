# Each descriptor is a pack (`mh1`, `iko-collector`) or a single card
# (`mh1/255`, `m19/306/foil`), optionally prefixed by a count.
#
# The count must be followed by a space - `36x mh1` or `36 mh1`, not `36xmh1`,
# so it needs quoting in the shell. Without the separator the prefix is
# ambiguous with the set codes that start with a digit: `2x2/100` reads as
# either two copies of `2/100` or one copy of Double Masters 2022 card 100,
# and only the second names a set that exists.
class Sealed
  COUNT_PREFIX = %r[\A(\d+)\s*x?\s+(.*)\z]m

  def initialize(db, *pack_descriptors)
    @db = db
    @fixed = []
    @packs = []
    pack_descriptors.each do |descriptor|
      count = 1
      count, descriptor = $1.to_i, $2 if descriptor =~ COUNT_PREFIX
      if descriptor.include?("/")
        add_card count, descriptor
      else
        add_pack count, descriptor
      end
    end
  end

  # Booster codes, same as the sealed simulator's - a bare set code is that
  # set's default booster (`nph` is `nph-draft`), which PackFactory alone
  # cannot resolve
  def add_pack(count, booster_code)
    pack = @db.supported_booster_types[booster_code.downcase]
    raise "No pack for #{booster_code}" unless pack
    @packs << [count, pack]
  end

  def add_card(count, description)
    set_code, number, foil = description.split("/", 3)
    set = @db.sets[set_code.downcase] or raise "Can't find set #{set_code}"
    card = set.printings.find{|c| c.number.downcase == number.downcase} or raise "Can't find card #{set_code}/#{number}"
    physical_card = PhysicalCard.for(card, foil == "foil")
    count.times{ @fixed << physical_card }
  end

  def call
    cards = @fixed.dup
    @packs.each do |count, pack|
      count.times do
        cards.push *pack.open
      end
    end
    cards
  end
end
