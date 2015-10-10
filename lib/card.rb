# This class represents card from index point of view, not from data point of view
# (thinking in solr/lucene terms)

class Card
  attr_reader :data
  def initialize(data)
    @data = data
  end

  def colors
    (@data["colors"] || []).map{|c| color_codes.fetch(c)}
  end

  def color_identity
    ci = colors.dup
    text.scan(/{(.*?)}/).each do |sym,|
      case sym.downcase
      when /\A(\d+|[txyz])\z/
        # OK
      when /\A([wubrg])\z/
        ci << $1
      when /\A([wubrg])\/([wubrg])\z/
        ci << $1 << $2
      else
        warn sym
        require 'pry'; binding.pry
      end
    end
    ci.uniq
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

private

  def color_names
    {"g"=>"Green", "r"=>"Red", "b"=>"Black", "u"=>"Blue", "w"=>"White"}
  end

  def color_codes
    {"White"=>"w", "Blue"=>"u", "Black"=>"b", "Red"=>"r", "Green"=>"g"}
  end
end
