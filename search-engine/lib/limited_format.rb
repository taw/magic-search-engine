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

  # Packs picked at random out of a list, on top of the fixed ones
  def random_boosters
    pools.flat_map(&:random_boosters)
  end

  # Play variants the frontend has rules text for. Anything new gets a
  # placeholder page until someone writes that text.
  DESCRIBABLE_PLAY_VARIANTS = [nil, "multiplayer", "two-headed-giant", "commander"]

  def describable_play_variant?
    DESCRIBABLE_PLAY_VARIANTS.include?(play_variant)
  end

  # A draft we can describe in full: we know every pack, and we know how the
  # set is played.
  def describable_draft?
    format_type == "draft" and
      booster_order.any? and
      describable_play_variant?
  end

  # A sealed format we can describe in full: every pool is one we can describe,
  # and we know how the set is played. Anything fancier gets a placeholder.
  def describable_sealed?
    format_type == "sealed" and
      pools.any? and
      pools.all?(&:describable?) and
      describable_play_variant?
  end

  # 903.13e - in a Commander Draft you may use up to two copies of a filler
  # commander even though you did not draft them. Which card that is depends on
  # the set, and it is always a card of that set, so just look it up.
  FILLER_COMMANDER_NAMES = ["The Prismatic Piper", "Faceless One"]

  def filler_commanders
    return [] unless play_variant == "commander"
    @filler_commanders ||= @set.printings
      .select{|printing| FILLER_COMMANDER_NAMES.include?(printing.name)}
      .uniq(&:name)
  end

  # Pools a sealed format is handed out as. There is just one, unless the player
  # picked a faction/guild at the prerelease, in which case there is one each.
  def pools
    @pools ||=
      if @data["variants"]
        @data["variants"].map{|slug, pool_data| SealedPool.new(self, slug, pool_data)}
      elsif @data["boosters"]
        [SealedPool.new(self, nil, @data)]
      else
        []
      end
  end

  def playable_promo_cards
    pools.flat_map(&:playable_promo_cards)
  end

  def unplayable_promo_cards
    pools.flat_map(&:unplayable_promo_cards)
  end

  def promo_cards
    pools.flat_map(&:promo_cards)
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
end
