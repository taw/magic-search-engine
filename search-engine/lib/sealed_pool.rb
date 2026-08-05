# One pool of a sealed format - the packs and promos handed to one player.
#
# A format has just one pool, unless the player picked a faction/guild at the
# prerelease, in which case there is one pool for each choice.
class SealedPool
  attr_reader :limited_format, :slug, :data

  def initialize(limited_format, slug, data)
    @limited_format = limited_format
    @slug = slug
    @data = data
  end

  def db
    @limited_format.db
  end

  # "Azorius", or nil for a format without a choice
  def name
    @slug&.split("-")&.map(&:capitalize)&.join(" ")
  end

  # Packs of the pool, as [count, pack], in the order they are listed
  def boosters
    @boosters ||= (@data["boosters"] || []).map{|code, count|
      pack = db.supported_booster_types[code]
      warn "#{inspect} uses unknown booster #{code}" unless pack
      pack && [count, pack]
    }.compact
  end

  # Packs picked at random out of a list, on top of the fixed ones
  def random_boosters
    @random_boosters ||= (@data["random_boosters"] || []).map{|entry|
      RandomBoosters.new(self, entry)
    }
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

  # A pool we can describe in full - every pack is one we know, including the
  # ones the player got at random
  def describable?
    boosters.size == (@data["boosters"] || []).size and
      boosters.any? and
      random_boosters.all?(&:describable?)
  end

  def inspect
    "SealedPool(#{@limited_format.set_code}, #{@limited_format.type}#{@slug ? ", #{@slug}" : ""})"
  end

  private

  # The foil tag is part of the card, so promos are just PhysicalCards
  def promo_cards_for(key)
    (@data[key] || []).map{|promo_data| promo_card(promo_data)}.compact
  end

  def promo_card(promo_data)
    set = db.sets[promo_data["set_code"]]
    printing = set && set.printing_by_number[promo_data["number"]]
    unless printing
      warn "#{inspect} has unknown promo card #{promo_data["name"]} [#{promo_data["set_code"].upcase}:#{promo_data["number"]}]"
      return nil
    end
    PhysicalCard.for(printing, promo_data["foil"])
  end
end
