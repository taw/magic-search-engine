# This class represents card from index point of view, not from data point of view
# (thinking in solr/lucene terms)
require_relative "ban_list"
require_relative "bitmap_flag"
require_relative "legality_information"

# 86,000 of these across the index. A two-member Struct fits in the smallest
# object ruby has; the {"date" =>, "text" =>} hash this used to be needed four
# times as much memory to say the same thing.
Ruling = Struct.new(:date, :text)

class Card
  extend BitmapFlag

  bitmap_flags(
    :alchemy,
    :augment,
    :brawler,
    :commander,
    :front,
    :funny,
    :game_changer,
    :has_alchemy,
    :modal,
    :partner,
    :reserved,
    :secondary,
    :special_format,
  )

  attr_reader :data, :printings
  attr_writer :printings # For db subset

  attr_reader(
    :color_identity,
    :color_indicator_colors,
    :color_indicator,
    :colors,
    :decklimit,
    :defense,
    :display_mana_cost,
    :display_power,
    :display_toughness,
    :foreign_names_normalized,
    :foreign_names,
    :fulltext_normalized,
    :fulltext,
    :hand,
    :in_spellbook,
    :keywords,
    :layout,
    :life,
    :loyalty,
    :mana_cost,
    :mana_hash,
    :mv,
    :name,
    :name_slug,
    :names,
    :power,
    :produces,
    :related,
    :reminder_text,
    :rulings,
    :short_name,
    :specialized,
    :specializes,
    :spellbook,
    :stemmed_name,
    :text_normalized,
    :text,
    :toughness,
    :typeline,
    :types,
  )

  alias cmc mv

  # Set by CardDatabase initialization, cards ordered by name
  attr_accessor :name_sort_index

  def initialize(name, data)
    @printings = []
    @flags = 0
    # The name is the key the card is stored under in the index, not part of its data
    @name = name
    @stemmed_name = -@name.downcase.normalize_accents.gsub(/s\b/, "").tr("-", " ")
    @names = data["ns"]
    @layout = data["l"]
    @colors = data["c"] || ""
    @color_identity = data["ci"]
    self.funny = data["fu"]
    self.special_format = data["sf"]
    @fulltext = -(data["o"] || "")
    @fulltext_normalized = -@fulltext.normalize_accents
    @text = @fulltext
    # Parenthetical text is reminder text on ordinary cards, but on funny, special format
    # and dungeon cards it is often the only statement of a rule that appears nowhere else -
    # "Hidden agenda" and "(An ongoing scheme remains face up until it's abandoned.)" have no
    # other printing to explain them.
    @text = @text.gsub(/\s*\([^\(\)]*\)/, "") unless funny? or special_format? or @layout == "dungeon"
    @text = -@text.sub(/\s*\z/, "").gsub(/ *\n/, "\n").sub(/\A\s*/, "")
    @text_normalized = -@text.normalize_accents
    self.augment = @text =~ /augment \{/i
    self.modal = @text =~ /(choose|opponent chooses) .*\n•/im
    @mana_cost = data["m"]
    self.reserved = data["rs"]
    self.game_changer = data["gc"]
    types = data["t"]
    subtypes = data["tb"]
    supertypes = data["tp"]
    @types = [types, subtypes, supertypes]
      .flat_map{|t| t || []}
      .map{|t| -t.downcase.tr("’\u2212", "'-").gsub("'s", "").tr(" ", "-")}
    @mv = data["v"] || 0
    @power = data["p"] ? smart_convert_powtou(data["p"]) : nil
    @toughness = data["to"] ? smart_convert_powtou(data["to"]) : nil
    @loyalty = data["ly"] ? smart_convert_powtou(data["ly"]) : nil
    @display_power = data["dp"] ? data["dp"] : @power
    @display_toughness = data["dt"] ? data["dt"] : @toughness
    @display_mana_cost = data["hm"] ? nil : @mana_cost
    self.alchemy = data["al"]
    self.has_alchemy = data["ha"]
    @decklimit = data["dl"]
    @hand = data["hd"]
    @life = data["lf"]
    @rulings = data["r"]&.flat_map{|date, texts| texts.map{|text| Ruling.new(date, text)}}
    self.secondary = data["s"]
    self.partner = data["ip"]
    self.commander = data["cm"]
    self.brawler = data["br"]
    @specialized = data["sd"]
    @specializes = data["ss"]
    @spellbook = data["sb"]
    @in_spellbook = data["is"]
    # A single name per language is stored unwrapped, and stays that way -
    # wrapping each of them in an array of its own was 488,000 arrays.
    # Splat on use, [*names] copes with either shape.
    @foreign_names = data["f"] ? data["f"].transform_keys(&:to_sym) : {}
    raise "Foreign data with empty value for #{name}" if @foreign_names.any?{|_, v| [*v].empty?}
    @foreign_names_normalized = @foreign_names.transform_values{|names|
      names.is_a?(Array) ? names.map{|n| hard_normalize(n)} : hard_normalize(names)
    }
    @related = data["rl"]
    @typeline = [supertypes, types].compact.flatten.join(" ")
    if subtypes
      @typeline += " - #{subtypes.join(" ")}"
    end
    @typeline = -@typeline
    if data["k"]
      @keywords = data["k"].map{|k| -k}
    end
    @defense = data["df"]
    @produces = data["pr"]&.freeze
    @short_name = data["sn"]&.freeze
    calculate_mana_hash
    calculate_color_indicator
    calculate_reminder_text
    self.front = (!secondary? or @layout == "aftermath" or @layout == "flip" or @layout == "adventure" or @layout == "prepare")
    @name_slug = name
      .normalize_accents
      .gsub("'s", "s")
      .gsub("I'm", "Im")
      .gsub("You're", "Youre")
      .gsub("R&D", "RnD")
      .gsub(/[^a-zA-Z0-9\-]+/, "-")
      .gsub(/(\A-)|(-\z)/, "")
      .freeze
  end

  def back?
    !front?
  end

  def primary?
    !secondary?
  end

  def custom?
    # a card is custom if it has been printed in at least one custom set (to exclude uncards)...
    return false unless printings.any? { |printing| printing.set.custom? }
    # ...and hasn't been printed in an official black-border set (to exclude custom reprints of official cards)
    printings.all? { |printing| printing.set.custom? or printing.set.funny? }
  end

  def has_multiple_parts?
    !!@names
  end

  # Decklists group cards by type. A card with more than one type goes into the
  # first group matching here, which is not the order the groups are displayed
  # in - Dryad Arbor is a creature, Urza's Saga is a land, and every artifact
  # creature is a creature.
  TYPE_GROUPS = [
    ["creature",     [1, "Creature"].freeze],
    ["land",         [7, "Land"].freeze],
    ["planeswalker", [2, "Planeswalker"].freeze],
    ["instant",      [3, "Instant"].freeze],
    ["sorcery",      [4, "Sorcery"].freeze],
    ["artifact",     [5, "Artifact"].freeze],
    ["enchantment",  [6, "Enchantment"].freeze],
  ].freeze
  OTHER_TYPE_GROUP = [8, "Other"].freeze

  # [sort index, name] of the decklist section this card belongs to
  def type_group
    TYPE_GROUPS.each do |type, group|
      return group if @types.include?(type)
    end
    OTHER_TYPE_GROUP
  end

  def inspect
    "Card(#{name})"
  end

  include Comparable

  def <=>(other)
    name_sort_index <=> other.name_sort_index
  end

  def to_s
    inspect
  end

  def legality_information(date=nil)
    LegalityInformation.new(self, date)
  end

  def default_printing
    @printings.min_by(&:default_sort_index)
  end

  def first_release_date
    @first_release_date ||= @printings.map(&:release_date).compact.min
  end

  def not_released_yet?
    first_release_date > Date.today
  end

  # If a card has non-promo printing, pick oldest, ignore promos
  # If a card has only promo printings, pick oldest
  # This deals with prerelease promos and similar
  #
  # Promos released at same time or earlier than the first release date
  # are not considered reprints
  def first_regular_release_date
    @first_regular_release_date ||= begin
      promo_printings, regular_printings = printings.partition{|cp| cp.set.types.include?("promo")}
      regular_printings.map(&:release_date).min || promo_printings.map(&:release_date).min
    end
  end

  def last_release_date
    @last_release_date ||= @printings.map(&:release_date).compact.max
  end

  def allowed_in_any_number?
    @types.include?("basic") or (
      @text and @text.include?("A deck can have any number of cards named")
    )
  end

  def count_prints
    printings.size
  end

  def count_paperprints
    printings.count(&:paper?)
  end

  def count_sets
    printings.map(&:set).uniq.size
  end

  def count_papersets
    printings.select(&:paper?).map(&:set).uniq.size
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
      when /\A[wubrgxyzcsdl]\z/
        # x is basically a color for this kind of queries
        @mana_hash[m] += 1
      when /\Ah([wubrg])\z/
        @mana_hash[$1] += 0.5
      when /\A([wubrg])\/([wubrg])\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\A([wubrgc])\/p\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\A2\/([wubrg])\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\A([wubrg])\/([wubrg])\/p\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\Ac\/([wubrg])\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      else
        raise "Unrecognized mana type: #{m}"
      end
      ""
    end
    raise "Mana query parse error: #{mana}" unless mana.empty?
  end

  def normalize_mana_symbol(sym)
    -sym.downcase.tr("/{}", "").chars.sort.join
  end

  # unicode_normalize already hands back a copy nobody else holds, so the
  # accent-stripping and downcasing can happen in it rather than allocating
  # two more. This runs for every foreign name on every card.
  def hard_normalize(s)
    result = s.unicode_normalize(:nfd)
    result.gsub!(/\p{Mn}/, "")
    result.downcase!
    -result
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
      # PatchDisplayPowerToughness spells these N+*, never *+N, and Sorter::PT_ORDER
      # needs an entry for each of them, so this stays a closed list
      case val
      when "*", "*²", "1+*", "2+*", "7-*", "X", "∞", "?", "1d4+1"
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

  def calculate_color_indicator
    colors_inferred_from_mana_cost = (@mana_hash || {}).keys
      .flat_map do |x|
        next [] if x =~ /[?xyzcsdl]/
        x = x.sub(/[p2]/, "")
        if x =~ /\A[wubrg]+\z/
          x.chars
        else
          raise "Unknown mana cost: #{x}"
        end
      end
      .uniq

    actual_colors = @colors.chars

    if colors_inferred_from_mana_cost.sort == actual_colors.sort
      @color_indicator = nil
    else
      @color_indicator = Color.color_indicator_name(actual_colors)
    end
    if @color_indicator
      @color_indicator_colors = @colors
    end
  end

  def calculate_reminder_text
    @reminder_text = nil
    basic_land_types = (["forest", "island", "mountain", "plains", "swamp"] & @types.to_a)
      .sort.join(" ")
    if not basic_land_types.empty?
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
      when "forest plains swamp"
        "{W}, {B}, or {G}"
      when "forest island mountain"
        "{G}, {U}, or {R}"
      when "island mountain plains"
        "{U}, {R}, or {W}"
      when "mountain plains swamp"
        "{R}, {W}, or {B}"
      when "forest island swamp"
        "{B}, {G}, or {U}"
      when "forest mountain plains"
        "{R}, {G}, or {W}"
      when "island plains swamp"
        "{W}, {U}, or {B}"
      when "forest island plains"
        "{G}, {W}, or {U}"
      when "island mountain swamp"
        "{U}, {B}, or {R}"
      when "forest mountain swamp"
        "{B}, {R}, or {G}"
      else
        raise "No idea what's correct line for #{basic_land_types.inspect}"
      end
      @reminder_text = "({T}: Add #{mana}.)"
    elsif layout == "flip" and secondary?
      # Awkward wording
      other_name = (@names - [@name])[0]
      @reminder_text = "(#{@name} keeps color and mana cost of #{other_name} when flipped)"
    end
  end
end
