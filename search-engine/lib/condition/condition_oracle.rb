class ConditionOracle < ConditionSimple
  # Ways a card can refer to itself other than by name
  SELF_REFERENCE = "this (?:land|artifact|creature|enchantment|Aura|Vehicle|Equipment|Case|permanent|Class|Siege|Spacecraft|Attraction|card|scheme|contraption|sorcery|battle|dungeon|spell|planeswalker|plane|door|room|saga|phenomenon|conspiracy)"

  def initialize(text)
    @text = text
    @has_cardname = !!(@text =~ /~/)
    # Everything below is built from this one normalized string, so that ~ queries
    # normalize exactly like plain ones - accents, curly quotes and mana symbols alike
    @base_rx_str = Regexp.escape(normalize_mana(normalize_text(@text)))
    if @has_cardname
      @regexp_prefilter = Regexp.new(@base_rx_str.gsub("~", ".*"), Regexp::IGNORECASE)
      # Cards which refer to themselves without naming themselves don't need a per-card regexp
      @self_reference_regexp = Regexp.new(@base_rx_str.gsub("~", "(?:#{SELF_REFERENCE})"), Regexp::IGNORECASE)
      # With a single ~ that check has already settled the self-reference case by the time
      # we build the per-card regexp, so it only needs the names. Only a query using ~ more
      # than once can still need both, and it's the big alternation that costs to compile.
      @tilde_self_reference = (@text.count("~") > 1 ? "|" + SELF_REFERENCE : "")
    end
    @regexp = Regexp.new(@base_rx_str, Regexp::IGNORECASE)
  end

  def match?(card)
    if @has_cardname
      # Two regexps shared by every card settle most of them, which matters a lot -
      # only what survives both needs a regexp compiled for this card in particular
      text = oracle_text(card)
      return false unless text =~ @regexp_prefilter
      return true if text =~ @self_reference_regexp
      tilde_rx_str = "(?:" + names_rx_str(card) + @tilde_self_reference + ")"
      text =~ Regexp.new(@base_rx_str.gsub("~", tilde_rx_str), Regexp::IGNORECASE)
    else
      oracle_text(card) =~ @regexp
    end
  end

  def to_s
    "o:#{maybe_quote(@text)}"
  end

  private

  # Which text gets searched is the only thing fo: does differently
  def oracle_text(card)
    card.text_normalized
  end

  # Modern templating often shortens the name it refers to itself by, and which part
  # it keeps isn't predictable, so the indexer mines it out of the card's own text
  # (see PatchShortName): "Ajani deals 3 damage" on Ajani Vengeant.
  def names_rx_str(card)
    [card.name, card.short_name].compact.map{|name|
      Regexp.escape(normalize_text(name))
    }.join("|")
  end

  def normalize_mana(text)
    text.gsub(%r[\{(.*?)\}]) do
      normalize_mana_symbol($&)
    end
  end

  # Cards print each two-part symbol in one fixed order, so a query written any other
  # way ({B/W}, {W/B} and {WB} are all the same symbol) has to be moved onto it.
  # Keyed by the symbol's characters sorted, which is what makes order not matter.
  MANA_NORMALIZATION = %w[
    {W/U} {W/B} {U/B} {U/R} {B/R} {B/G} {R/G} {R/W} {G/W} {G/U}
    {2/W} {2/U} {2/B} {2/R} {2/G}
    {W/P} {U/P} {B/P} {R/P} {G/P} {C/P}
  ].to_h{|symbol| [symbol[1..-2].downcase.delete("/").chars.sort.join, symbol] }.freeze

  def normalize_mana_symbol(symbol)
    return symbol unless symbol[0] == "{" and symbol[-1] == "}" and symbol.size >= 4
    MANA_NORMALIZATION[symbol[1..-2].downcase.tr("/", "").chars.sort.join] or symbol
  end
end
