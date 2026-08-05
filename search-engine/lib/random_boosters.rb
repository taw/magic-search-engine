# Packs of a sealed pool the player got at random out of a short list, instead
# of being handed a fixed pack - like the allied guild booster of the Dragon's
# Maze prerelease, which was one of the four guilds allied with the one you
# picked.
class RandomBoosters
  attr_reader :sealed_pool, :data

  def initialize(sealed_pool, data)
    @sealed_pool = sealed_pool
    @data = data
  end

  def db
    @sealed_pool.db
  end

  # How many packs out of the list the player got
  def pick
    @data["pick"]
  end

  # What the event called these packs. The list of packs alone doesn't say what
  # they have in common, so the data file spells it out.
  def name
    @data["name"] || "random booster"
  end

  # Packs the pick could have been
  def packs
    @packs ||= (@data["from"] || []).map{|code|
      pack = db.supported_booster_types[code]
      warn "#{inspect} uses unknown booster #{code}" unless pack
      pack
    }.compact
  end

  # A pick we can describe in full - we know every pack it could have been
  def describable?
    packs.size == (@data["from"] || []).size and packs.any?
  end

  def inspect
    "RandomBoosters(#{@sealed_pool.inspect}, #{name})"
  end
end
