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
    @types = Set[*types.split]
    if @types.include?("*")
      @match_all = true
    else
      @match_all = false
    end
  end

  def match?(card)
    return true if @match_all
    card.types >= @types
  end

  def to_s
    "t:#{maybe_quote(@types.sort.join(' '))}"
  end
end
