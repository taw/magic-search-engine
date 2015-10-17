class ConditionFormat < Condition
  def initialize(format)
    @format = format.downcase
    @format = "commander" if @format == "edh"
  end

  def search(db)
    max_date = db.sets[@time].release_date if @time
    db.printings.select do |card|
      legality_ok?(card_legality(card, max_date))
    end.to_set
  end

  def metadata=(options)
    @time = options[:time]
  end

  def to_s
    "f:#{maybe_quote(@format)}"
  end

  private

  def legality_ok?(legality)
    legality == "legal" or legality == "restricted"
  end

  def card_legality(card, max_date)
    if max_date
      printings = card.printings.select{|c| c.release_date <= max_date}.map(&:set_code)
      CardLegality.new(@name, printings, card.layout, card.types).legality[@format]
    else
      card.legality(@format)
    end
  end
end
