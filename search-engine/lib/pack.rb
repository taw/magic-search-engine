class Pack
  def initialize(set, distribution)
    @set = set
    @distribution = distribution
    @pools = {}
  end

  def open
    cards = []
    @distribution.each do |category, count|
      cards.push *pool(category).sample(count)
    end
    cards
  end

  def pool(category)
    @pools[category] ||= begin
      case category
      when :basic, :common, :uncommon
        @set.printings.select{|c| c.rarity == category.to_s}
      when :rare_or_mythic
        @set.printings.select{|c| c.rarity == "rare"} * 2 +
        @set.printings.select{|c| c.rarity == "mythic"}
      else
        raise "Unknown category #{category}"
      end
    end
  end

  def self.[](db, set_code)
    set = db.sets[set_code.downcase]
    raise "Invalid set code #{set_code}" unless set
    case set_code
    when "M10", "M11", "M12", "M13"
      Pack.new(set, {basic: 1, common: 10, uncommon: 3, rare_or_mythic: 1})
    else
      raise "No known packs for set #{set_code}"
    end
  end
end
