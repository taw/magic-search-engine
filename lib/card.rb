# This class represents card from index point of view, not from data point of view
# (thinking in solr/lucene terms)
require "date"

class Card
  attr_reader :data, :printings
  attr_writer :printings # For db subset
  def initialize(data)
    @data = data
    @printings = []
  end

  def name
    @data["name"].gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü", "Aaaaaeeeioouuu")
  end

  def names
    @data["names"]
  end

  def layout
    @data["layout"]
  end

  def colors
    @data["colors"] || []
  end

  def mana_cost
    @data["manaCost"] ? @data["manaCost"].downcase : nil
  end

  attr_writer :color_identity
  def color_identity
    @color_identity ||= begin
      return partial_color_identity unless @data["names"]
      raise "Multi-part cards need to have CI set by database"
    end
  end

  def has_multiple_parts?
    !!@data["names"]
  end

  def partial_color_identity
    ci = colors.dup
    text.scan(/{(.*?)}/).each do |sym,|
      case sym.downcase
      when /\A(\d+|[½∞txyzsqp])\z/
        # 12xyz - colorless
        # ½∞ - unset colorless
        # t - tap
        # q - untap
        # s - snow
        # p - generic Phyrexian mana (like on Rage Extractor text)
      when /\A([wubrg])\z/
        ci << $1
      when /\A([wubrg])\/p\z/
        # Phyrexian mana
        ci << $1
      when /\Ah([wubrg])\z/
        # Unset half colored mana
        ci << $1
      when /\A2\/([wubrg])\z/
        ci << $1
      when /\A([wubrg])\/([wubrg])\z/
        ci << $1 << $2
      else
        warn sym
        require 'pry'; binding.pry
      end
    end
    types.each do |t|
      tci = {"forest" => "g", "mountain" => "r", "plains" => "w", "island" => "u", "swamp" => "b"}[t]
      ci << tci if tci
    end
    ci.uniq
  end

  def types
    ["types", "subtypes", "supertypes"].map{|t| @data[t] || []}.flatten.map(&:downcase)
  end

  def legality(format)
    format = format.downcase
    format = "commander" if format == "edh"
    @data["legalities"][format]
  end

  def cmc
    @data["cmc"] || 0
  end

  # Normalize unicode, remove remainder text
  def text
    text = (@data["text"] || "").gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü", "Aaaaaeeeioouuu")
    text.gsub(/\([^\(\)]*\)/, "")
  end

  def power
    @data["power"] ?  @data["power"].to_f : nil
  end

  def toughness
    @data["toughness"] ?  @data["toughness"].to_f : nil
  end

  def loyalty
    @data["loyalty"] ?  @data["loyalty"].to_f : nil
  end

  def inspect
    "Card(#{name})"
  end

  include Comparable
  def <=>(other)
    name <=> other.name
  end

  def to_s
    inspect
  end
end
