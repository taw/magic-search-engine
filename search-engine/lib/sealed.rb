class Sealed
  def initialize(db, *pack_descriptors)
    @db = db
    @factory = PackFactory.new(db)
    @fixed = []
    @packs = []
    pack_descriptors.each do |descriptor|
      case descriptor
      when %r[\A(\d+)x(.*/.*)]
        add_card $1.to_i, $2
      when %r[\A(.*/.*)]
        add_card 1, descriptor
      when /\A(\d+)x(.*)/
        add_pack $1.to_i, $2
      else
        add_pack 1, descriptor
      end
    end
  end

  def add_pack(count, set_code)
    set_code, variant = set_code.split("-", 2)
    pack = @factory.for(set_code, variant)
    unless pack
      raise "No pack for set #{set_code}#{variant && " variant #{variant}"}"
    end
    @packs << [count, pack]
  end

  def add_card(count, description)
    set_code, number, foil = description.split("/", 3)
    set = @db.sets[set_code.downcase] or caise "Can't find set #{set_code}"
    card = set.printings.find{|c| c.number.downcase == number.downcase} or raise "Can't find card #{set_code}/#{number}"
    @fixed << PhysicalCard.for(card, foil == "foil")
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
