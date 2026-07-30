class ConditionOracle < ConditionSimple
  # Ways a card can refer to itself other than by name
  SELF_REFERENCE = "this (?:land|artifact|creature|enchantment|Aura|Vehicle|Equipment|Case|permanent|Class|Siege|Spacecraft|Attraction|card|scheme|contraption|sorcery|battle|dungeon|spell|planeswalker|plane|door|room|saga|phenomenon|conspiracy)"

  def initialize(text)
    @text = text
    @has_cardname = !!(@text =~ /~/)
    if @has_cardname
      @regexp_prefilter = Regexp.new(Regexp.escape(text).gsub("~", ".*"), Regexp::IGNORECASE)
      @base_rx_str = Regexp.escape(normalize_text(@text))
      # Cards which refer to themselves without naming themselves don't need a per-card regexp
      @self_reference_regexp = Regexp.new(@base_rx_str.gsub("~", "(?:#{SELF_REFERENCE})"), Regexp::IGNORECASE)
    end
    @regexp = build_regexp(normalize_mana(normalize_text(@text)))
  end

  def match?(card)
    if @has_cardname
      # This speeds it up a lot
      text = card.text_normalized
      return false unless text =~ @regexp_prefilter
      return true if text =~ @self_reference_regexp
      tilde_rx_str = "(?:" + names_rx_str(card) + "|" + SELF_REFERENCE + ")"
      text =~ Regexp.new(@base_rx_str.gsub("~", tilde_rx_str), Regexp::IGNORECASE)
    else
      card.text_normalized =~ @regexp
    end
  end

  def to_s
    "o:#{maybe_quote(@text)}"
  end

  private

  # Modern templating often shortens the name it refers to itself by, and which part
  # it keeps isn't predictable, so the indexer mines it out of the card's own text
  # (see PatchShortName): "Ajani deals 3 damage" on Ajani Vengeant.
  def names_rx_str(card)
    [card.name, card.short_name].compact.map{|name|
      Regexp.escape(normalize_text(name))
    }.join("|")
  end

  def build_regexp(text)
    Regexp.new(Regexp.escape(text), Regexp::IGNORECASE)
  end

  def normalize_mana(text)
    text.gsub(%r[\{(.*?)\}]) do
      normalize_mana_symbol($&)
    end
  end

  # Don't try too hard
  # 2-brid and a lot of other weirdness is never used in Oracle text
  def normalize_mana_symbol(symbol)
    return symbol unless symbol[0] == "{" and symbol[-1] == "}" and symbol.size >= 4
    parts = symbol[1..-2].downcase.tr("/", "").chars.sort.join
    normalization_table = {
      "bg" => "{B/G}",
      "bp" => "{B/P}",
      "br" => "{B/R}",
      "gp" => "{G/P}",
      "gu" => "{G/U}",
      "gw" => "{G/W}",
      "gr" => "{R/G}",
      "pr" => "{R/P}",
      "rw" => "{R/W}",
      "bu" => "{U/B}",
      "pu" => "{U/P}",
      "ru" => "{U/R}",
      "pw" => "{W/P}",
      "uw" => "{W/U}",
    }
    normalization_table[parts] or symbol
  end
end
