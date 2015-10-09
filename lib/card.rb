class Card
  attr_reader :data
  def initialize(data)
    @data = data
  end

  def colors
    @data["colors"] || []
  end

  def types
    ["types", "subtypes", "supertypes"].map{|t| @data[t] || []}.flatten.map(&:downcase)
  end

  def rarity
    r = @data["rarity"].downcase
    return "mythic" if r == "mythic rare"
    r
  end

  def legality(format)
    leg = @data["legalities"].find{|leg| leg["format"].downcase == format}
    if leg
      leg["legality"].downcase
    else
      nil
    end
  end

  def artist
    @data["artist"].downcase
  end

  def cmc
    @data["cmc"] || 0
  end

  def text
    @data["text"] || ""
  end

  def flavor
    @data["flavor"] || ""
  end

  def power
    @data["power"] ?  @data["power"].to_i : nil
  end

  def toughness
    @data["toughness"] ?  @data["toughness"].to_i : nil
  end

  def method_missing(m)
    if @data.has_key?(m.to_s)
      @data[m.to_s]
    else
      super
    end
  end

  def inspect
    "Card(#{@data["name"]})"
  end
end
