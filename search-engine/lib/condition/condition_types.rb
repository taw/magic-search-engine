# FIXME: t:* is special case, it's massive hack here
class ConditionTypes < ConditionSimple
  def initialize(types)
    # * cleanup unicode
    # * Urza's -> Urza
    # * Some planes have multiword names, turn them into dashes
    types = types
      .downcase
      .tr("’\u2212", "'-")
      .gsub(/'s/, "")
      .gsub(/\s+/, " ")
      .gsub("new phyrexia", "new-phyrexia")
      .gsub("serra realm", "serra-realm")
      .gsub("bolas meditation realm", "bolas-meditation-realm")
      .gsub("tribal", "kindred")
    @types = types.split.uniq.sort
    if @types.include?("*")
      @match_all = true
    else
      @match_all = false
    end
  end

  def match?(card)
    return true if @match_all
    card_types = card.types
    @types.all? do |type|
      card_types.include?(type)
    end
  end

  def to_s
    "t:#{maybe_quote(@types.join(' '))}"
  end
end
