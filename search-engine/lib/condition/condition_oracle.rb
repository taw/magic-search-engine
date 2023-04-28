class ConditionOracle < ConditionSimple
  def initialize(text)
    @text = text
    @has_cardname = !!(@text =~ /~/)
    if @has_cardname
      @regexp_prefilter = Regexp.new(Regexp.escape(text).gsub("~", ".*"), Regexp::IGNORECASE)
    end
    @regexp = build_regexp(normalize_mana(normalize_text(@text)))
  end

  def match?(card)
    if @has_cardname
      # This speeds it up a lot
      return false unless card.text_normalized =~ @regexp_prefilter
      card.text_normalized =~ build_regexp(normalize_text(@text.gsub("~", card.name)))
    else
      card.text_normalized =~ @regexp
    end
  end

  def to_s
    "o:#{maybe_quote(@text)}"
  end

  private

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
