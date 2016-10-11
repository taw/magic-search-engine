# FIXME: t:* is special case, it's massive hack here
class ConditionTypes < ConditionSimple
  def initialize(types)
    # urza's -> urza, same with serra's, bolas's
    @types = Set[*types.downcase.tr("’\u2212", "'-").gsub(/'s/, "").split]
    @include_extras = false
    if @types.include?("*")
      @match_all = true
      @include_extras = true
    else
      @match_all = false
      extra_types = Set[
        "alara", "arkhos", "azgol", "belenon", "bolas's meditation realm", "conspiracy",
        "dominaria", "equilor", "ergamon", "fabacin", "innistrad", "iquatana", "ir",
        "kaldheim", "kamigawa", "kephalai", "kolbahan", "kyneth", "lorwyn", "mercadia",
        "mirrodin", "moag", "mongseng", "muraganda", "new phyrexia", "ongoing",
        "phenomenon", "phyrexia", "plane", "rabiah", "rath", "ravnica", "regatha",
        "scheme", "segovia", "serra's realm", "shadowmoor", "shandalar", "ulgrotha",
        "valla", "vanguard", "vryn", "wildfire", "xerex", "zendikar",
      ]
      unless (@types & extra_types).empty?
        @include_extras = true
      end
    end
  end

  def include_extras?
    @include_extras
  end

  def match?(card)
    return true if @match_all
    card.types >= @types
  end

  def to_s
    "t:#{maybe_quote(@types.sort.join(' '))}"
  end
end
