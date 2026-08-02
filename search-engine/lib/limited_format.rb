# One limited format of one set, like "draft" or "prerelease-sealed"
#
# The data is whatever indexer/bin/limited_formats_indexer exported for it.
# Only the parts the frontend needs are unpacked so far.
class LimitedFormat
  attr_reader :db, :set, :type, :data

  def initialize(db, set, type, data)
    @db = db
    @set = set
    @type = type
    @data = data
  end

  def set_code
    @set.code
  end

  # "draft" or "sealed" - "prerelease-sealed" is a sealed format
  def format_type
    @data["format_type"]
  end

  # "commander", "two-headed-giant" etc. for sets not played like normal limited
  def play_variant
    @data["play_variant"]
  end

  # Packs of a draft, in the order they are opened
  def booster_order
    (@data["booster_order"] || []).map{|code|
      pack = @db.supported_booster_types[code]
      warn "#{inspect} uses unknown booster #{code}" unless pack
      pack
    }.compact
  end

  # "faction", "guild" etc. if the player picked one, and it changed their pool
  def choice
    @data["choice"]
  end

  # Packs of a sealed pool, as [count, pack], in the order they are listed.
  # Only meaningful for formats with a single pool.
  def boosters
    pool = pools.size == 1 ? pools[0] : nil
    return [] unless pool
    (pool["boosters"] || []).map{|code, count|
      pack = @db.supported_booster_types[code]
      warn "#{inspect} uses unknown booster #{code}" unless pack
      pack && [count, pack]
    }.compact
  end

  # Packs picked at random out of a list, on top of the fixed ones
  def random_boosters
    pools.flat_map{|pool| pool["random_boosters"] || []}
  end

  # A sealed format we can describe in full: one pool, no random packs, and
  # played as ordinary limited. Anything fancier only gets a placeholder page.
  def simple_sealed?
    format_type == "sealed" and
      pools.size == 1 and
      random_boosters.empty? and
      play_variant.nil? and
      boosters.any?
  end

  # Pools a sealed format is handed out as. There is just one, unless the player
  # picked a faction/guild at the prerelease, in which case there is one each.
  def pools
    if @data["variants"]
      @data["variants"].values
    elsif @data["boosters"]
      [@data]
    else
      []
    end
  end

  def playable_promo_cards
    promo_cards_for("playable_promo_cards")
  end

  def unplayable_promo_cards
    promo_cards_for("unplayable_promo_cards")
  end

  def promo_cards
    playable_promo_cards + unplayable_promo_cards
  end

  # The data file and the card db each know whether a promo was foil, and they
  # agree on every promo we list. Report it if that ever stops being true,
  # rather than failing - the card db is regenerated from mtgjson.
  def verify_promo_cards!
    promo_cards.each do |promo|
      foiling = promo.main_front.foiling
      next if foiling == (promo.foil ? :foilonly : :nonfoil)
      warn "#{inspect} promo #{promo.inspect} disagrees with the card db, which says foiling=#{foiling}"
    end
  end

  def slug
    @type
  end

  def inspect
    "LimitedFormat(#{set_code}, #{type})"
  end

  def to_s
    "#{@set.name} #{@type.split("-").map(&:capitalize).join(" ")}"
  end

  private

  # The foil tag is part of the card, so promos are just PhysicalCards
  def promo_cards_for(key)
    pools.flat_map{|pool| (pool[key] || []).map{|promo_data| promo_card(promo_data)}}.compact
  end

  def promo_card(promo_data)
    set = @db.sets[promo_data["set_code"]]
    printing = set && set.printing_by_number[promo_data["number"]]
    unless printing
      warn "#{inspect} has unknown promo card #{promo_data["name"]} [#{promo_data["set_code"].upcase}:#{promo_data["number"]}]"
      return nil
    end
    PhysicalCard.for(printing, promo_data["foil"])
  end
end
