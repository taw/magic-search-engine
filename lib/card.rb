# This class represents card from index point of view, not from data point of view
# (thinking in solr/lucene terms)
require "date"
require_relative "ban_list"

class Card
  attr_reader :data, :printings
  attr_writer :printings # For db subset

  attr_reader :name, :names, :layout, :colors, :mana_cost, :reserved, :types
  attr_reader :partial_color_identity, :cmc, :text, :power, :toughness, :loyalty, :extra
  attr_reader :hand, :life, :rulings
  def initialize(data)
    @data = data
    @printings = []

    @name = normalize_name(@data["name"])
    @names = @data["names"] &&  @data["names"].map{|n| normalize_name(n)}
    @layout = @data["layout"]
    @colors = @data["colors"] || ""
    @text = (@data["text"] || "").gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-").gsub(/\([^\(\)]*\)/, "").sub(/\s*\z/, "")
    @mana_cost = @data["manaCost"] ? @data["manaCost"].downcase : nil
    @reserved = @data["reserved"] || false
    @types = ["types", "subtypes", "supertypes"].map{|t| @data[t] || []}.flatten.map{|t| t.downcase.tr("’\u2212", "'-").gsub("'s", "")}
    @cmc = @data["cmc"] || 0
    # Normalize unicode, remove remainder text
    @power = @data["power"] ? smart_convert_powtou(@data["power"]) : nil
    @toughness = @data["toughness"] ? smart_convert_powtou(@data["toughness"]) : nil
    @loyalty = @data["loyalty"] ?  @data["loyalty"].to_i : nil
    @partial_color_identity = calculate_partial_color_identity
    if ["vanguard", "plane", "scheme", "phenomenon"].include?(@layout) or @types.include?("conspiracy")
      @extra = true
    else
      @extra = false
    end
    @hand = @data["hand"]
    @life = @data["life"]
    @rulings = @data["rulings"]
  end

  attr_writer :color_identity
  def color_identity
    @color_identity ||= begin
      return partial_color_identity unless @names
      raise "Multi-part cards need to have CI set by database"
    end
  end

  def has_multiple_parts?
    !!@data["names"]
  end

  def typeline
    tl = [@data["supertypes"], @data["types"]].compact.flatten.join(" ")
    if data["subtypes"]
      tl += " - #{data["subtypes"].join(" ")}"
    end
    tl
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

  def all_legalities(date=nil)
    Format.all_legalities(self, date)
  end

  def first_release_date(filter="all")
    @printings.select{|pr| verify_set_type(pr, filter)}.map(&:release_date).compact.min
  end

  def last_release_date(filter="all")
    @printings.select{|pr| verify_set_type(pr, filter)}.map(&:release_date).compact.max
  end

  private

  def normalize_name(name)
    name.gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü", "Aaaaaeeeioouuu")
  end

  def smart_convert_powtou(val)
    if val !~ /\A-?[\d.]+\z/
      # It just so happens that "2+*" > "1+*" > "*" asciibetically
      # so we don't do any extra conversions,
      # but we might need to setup some eventually
      #
      # Including uncards
      # "*" < "*²" < "1+*" < "2+*"
      # but let's not get anywhere near that
      case val
      when "*", "*²", "1+*", "2+*", "7-*"
        val
      else
        require 'pry'; binding.pry
        raise "Unrecognized value #{val}"
      end
    elsif val.to_i == val.to_f
      val.to_i
    else
      val.to_f
    end
  end

  def calculate_partial_color_identity
    ci = colors.chars
    "#{mana_cost} #{text}".scan(/{(.*?)}/).each do |sym,|
      case sym.downcase
      when /\A(\d+|[½∞txyzsqpc])\z/
        # 12xyz - colorless
        # ½∞ - unset colorless
        # t - tap
        # q - untap
        # s - snow
        # p - generic Phyrexian mana (like on Rage Extractor text)
        # c - colorless mana
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
    ci.uniq.join
  end

  def verify_set_type(pr, type)
    case type
      when "full"
        !%w(promo masters).include?(pr.set_type) && pr.set_code != 'tpr'
      when "expert"
        %w(core expansion).include?(pr.set_type)
      else
        true
    end
  end
end
