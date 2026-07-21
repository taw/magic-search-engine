class ConditionIsHybrid < ConditionSimple
  # A symbol is hybrid if it can be paid in more than one way:
  # * two-color hybrid like {W/U}, including phyrexian ones like {G/W/P}
  # * monocolor hybrid like {2/W}
  # * colorless hybrid like {C/W}
  # Plain phyrexian like {W/P} or {C/P} is not hybrid.
  # Mana hash keys are alphabetized internally, so just count the characters.
  def match?(card)
    mana_hash = card.mana_hash or return false
    mana_hash.keys.any? do |symbol|
      colors = symbol.count("wubrg")
      colors >= 2 or (colors == 1 and symbol =~ /[2c]/)
    end
  end

  def to_s
    "is:hybrid"
  end
end
