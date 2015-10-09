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
