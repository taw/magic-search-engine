# This class represents card from index point of view, not from data point of view
# (thinking in solr/lucene terms)
require "date"
require_relative "ban_list"
require_relative "legality_information"

class Card
  ABILITY_WORD_LIST = ["Battalion", "Bloodrush", "Channel", "Chroma", "Cohort", "Constellation", "Converge", "Council's dilemma", "Delirium", "Domain", "Eminence", "Enrage", "Fateful hour", "Ferocious", "Formidable", "Gotcha", "Grandeur", "Hellbent", "Heroic", "Imprint", "Inspired", "Join forces", "Kinship", "Landfall", "Lieutenant", "Metalcraft", "Morbid", "Parley", "Radiance", "Raid", "Rally", "Revolt", "Spell mastery", "Strive", "Sweep", "Tempting offer", "Threshold", "Will of the council"]
  ABILITY_WORD_RX = %r[^(#{Regexp.union(ABILITY_WORD_LIST)}) —]i

  attr_reader :data, :printings
  attr_writer :printings # For db subset

  attr_reader :name, :exact_name, :names, :layout, :colors, :mana_cost, :reserved, :types
  attr_reader :partial_color_identity, :cmc, :text, :power, :toughness, :loyalty, :extra
  attr_reader :hand, :life, :rulings, :secondary, :foreign_names, :foreign_names_normalized, :stemmed_name
  attr_reader :mana_hash, :typeline, :funny, :color_indicator, :related
  attr_reader :reminder_text, :augment, :display_power, :display_toughness

  def initialize(data)
    @printings = []
    @name = normalize_name(data["name"])
    @exact_name = data["name"]
    @stemmed_name = @name.downcase.gsub(/s\b/, "").tr("-", " ")
    @names = data["names"]&.map{|n| normalize_name(n)}
    @layout = data["layout"]
    @colors = data["colors"] || ""
    @text = (data["text"] || "").gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-")
    @funny = data["funny"]
    unless @funny
      @text = @text.gsub(/\([^\(\)]*\)/, "")
    end
    @text = @text.sub(/\s*\z/, "").sub(/\A\s*/, "")
    @augment = !!(@text =~ /augment \{/i)
    @mana_cost = data["manaCost"] ? data["manaCost"].downcase : nil
    @reserved = data["reserved"] || false
    @types = ["types", "subtypes", "supertypes"].flat_map{|t| data[t] || []}.map{|t| t.downcase.tr("’\u2212", "'-").gsub("'s", "").tr(" ", "-")}.to_set
    @cmc = data["cmc"] || 0
    @power = data["power"] ? smart_convert_powtou(data["power"]) : nil
    @toughness = data["toughness"] ? smart_convert_powtou(data["toughness"]) : nil
    @loyalty = data["loyalty"] ? smart_convert_powtou(data["loyalty"]) : nil
    @display_power = data["display_power"] ? data["display_power"] : @power
    @display_toughness = data["display_toughness"] ? data["display_toughness"] : @toughness
    @partial_color_identity = calculate_partial_color_identity
    if ["vanguard", "plane", "scheme", "phenomenon"].include?(@layout) or @types.include?("conspiracy")
      @extra = true
    else
      @extra = false
    end
    @hand = data["hand"]
    @life = data["life"]
    @rulings = data["rulings"]
    @secondary = data["secondary"]
    @foreign_names = data["foreign_names"] || {}
    @foreign_names_normalized = {}
    @foreign_names.each do |lang, names|
      @foreign_names_normalized[lang] = names.map{|n| hard_normalize(n)}
    end
    @typeline = [data["supertypes"], data["types"]].compact.flatten.join(" ")
    @related = data["related"]
    if data["subtypes"]
      @typeline += " - #{data["subtypes"].join(" ")}"
    end
    calculate_mana_hash
    calculate_color_indicator
    calculate_reminder_text
  end

  attr_writer :color_identity
  def color_identity
    @color_identity ||= begin
      return partial_color_identity unless @names
      raise "Multi-part cards need to have CI set by database"
    end
  end

  def has_multiple_parts?
    !!@names
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

  def legality_information(date=nil)
    LegalityInformation.new(self, date)
  end

  def first_release_date
    @first_release_date ||= @printings.map(&:release_date).compact.min
  end

  def first_regular_release_date
    @first_regular_release_date ||= @printings
      .select{|cp| cp.set_code != "ptc"}
      .map(&:release_date)
      .compact
      .min
  end

  def last_release_date
    @last_release_date ||= @printings.map(&:release_date).compact.max
  end

  private

  def calculate_mana_hash
    if @mana_cost.nil?
      @mana_hash = nil
      return
    end
    @mana_hash = Hash.new(0)

    mana = @mana_cost.gsub(/\{(.*?)\}/) do
      m = $1
      case m
      when /\A\d+\z/
        @mana_hash["?"] += m.to_i
      when /\A[wubrgxyzc]\z/
        # x is basically a color for this kind of queries
        @mana_hash[m] += 1
      when /\Ah([wubrg])\z/
        @mana_hash[$1] += 0.5
      when /\A([wubrg])\/([wubrg])\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\A([wubrg])\/p\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\A2\/([wubrg])\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      else
        raise "Unrecognized mana type: #{m}"
      end
      ""
    end
    raise "Mana query parse error: #{mana}" unless mana.empty?
  end

  def normalize_mana_symbol(sym)
    sym.downcase.tr("/{}", "").chars.sort.join
  end

  def normalize_name(name)
    name.gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü", "Aaaaaeeeioouuu")
  end

  def hard_normalize(s)
    UnicodeUtils.downcase(UnicodeUtils.nfd(s).gsub(/\p{Mn}/, ""))
  end

  def smart_convert_powtou(val)
    return val unless val.is_a?(String)
    # Treat augment "+1"/"-1" strings as regular 1/-1 numbers for search engine
    # The view can use special format for them
    return val.to_i if val =~ /\A\+\d+\z/
    if val !~ /\A-?[\d.]+\z/
      # It just so happens that "2+*" > "1+*" > "*" asciibetically
      # so we don't do any extra conversions,
      # but we might need to setup some eventually
      #
      # Including uncards
      # "*" < "*²" < "1+*" < "2+*"
      # but let's not get anywhere near that
      case val
      when "*", "*²", "1+*", "2+*", "7-*", "X", "∞", "?"
        val
      else
        raise "Unrecognized value #{val.inspect}"
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
      when /\A(\d+|[½∞txyzsqpce])\z/
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
      when "chaos"
        # planechase special symbol, disregard
      else
        raise "Unknown mana symbol `#{sym}'"
      end
    end
    types.each do |t|
      tci = {"forest" => "g", "mountain" => "r", "plains" => "w", "island" => "u", "swamp" => "b"}[t]
      ci << tci if tci
    end
    ci.sort.uniq.join
  end

  def calculate_color_indicator
    colors_inferred_from_mana_cost = (@mana_hash || {}).keys
      .flat_map do |x|
        next [] if x =~ /[?xyzc]/
        x = x.sub(/[p2]/, "")
        if x =~ /\A[wubrg]+\z/
          x.chars
        else
          raise "Unknown mana cost: #{x}"
        end
      end

    actual_colors = @colors.chars

    if colors_inferred_from_mana_cost.sort == actual_colors.sort
      @color_indicator = nil
    else
      @color_indicator = color_indicator_name(actual_colors)
    end
  end

  def color_indicator_name(indicator)
    names = {"w" => "white", "u" => "blue", "b" => "black", "r" => "red", "g" => "green"}
    color_indicator = names.map{|c,cv| indicator.include?(c) ? cv : nil}.compact
    case color_indicator.size
    when 5
      "all colors"
    when 1, 2
      color_indicator.join(" and ")
    when 0
      # devoid and Ghostfire - for some reason they use rules text, not color indicator
      # "colorless"
      nil
    else # find phrasing for 3/4 colors
      raise
    end
  end

  def calculate_reminder_text
    @reminder_text = nil
    basic_land_types = (["forest", "island", "mountain", "plains", "swamp"] & @types.to_a)
      .sort.join(" ")
    return if basic_land_types.empty?
    # Listing them all explicitly due to wubrg wheel order
    mana = case basic_land_types
    when "plains"
      "{W}"
    when "island"
      "{U}"
    when "swamp"
      "{B}"
    when "mountain"
      "{R}"
    when "forest"
      "{G}"
    when "island plains"
      "{W} or {U}"
    when "plains swamp"
      "{W} or {B}"
    when "island swamp"
      "{U} or {B}"
    when "island mountain"
      "{U} or {R}"
    when "mountain swamp"
      "{B} or {R}"
    when "forest swamp"
      "{B} or {G}"
    when "forest mountain"
      "{R} or {G}"
    when "mountain plains"
      "{R} or {W}"
    when "forest plains"
      "{G} or {W}"
    when "forest island"
      "{G} or {U}"
    else
      raise "No idea what's correct line for #{basic_land_types.inspect}"
    end
    @reminder_text = "({T}: Add #{mana}.)"
  end
end
