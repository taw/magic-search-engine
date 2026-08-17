class FormatStandardBrawl < FormatStandard
  include BrawlDeckRules

  def format_pretty_name
    "Standard Brawl"
  end

  def deck_size
    60
  end

  def permanently_legal_cards?
    @time.nil? or @time >= Date.parse("2022-09-09")
  end

  # https://www.reddit.com/r/MagicArena/comments/tge9hb/did_brawl_legality_change_arena_doesnt_seem_to/i11ntcx/
  def in_format?(card)
    if permanently_legal_cards?
      ["Arcane Signet", "Command Tower"].include?(card.name) or super
    else
      super
    end
  end

  def cards_probably_in_format(db)
    if permanently_legal_cards?
      results = super
      results << db.cards["command tower"]
      results << db.cards["arcane signet"]
      results
    else
      super
    end
  end
end
