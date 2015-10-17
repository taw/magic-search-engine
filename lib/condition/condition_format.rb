class ConditionFormat < Condition
  def initialize(format)
    @format = format.downcase
    @format = "commander" if @format == "edh"
  end

  def search(db)
    db.printings.select do |card|
      legality = card.legality(@format)
      legality == "legal" or legality == "restricted"
    end.to_set
  end

  def metadata=(options)
    @time = options[:time]
  end

  def to_s
    "f:#{maybe_quote(@format)}"
  end
end
