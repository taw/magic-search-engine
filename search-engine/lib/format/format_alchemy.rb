class FormatAlchemy < FormatStandard
  def format_pretty_name
    "Alchemy"
  end

  # Format announced 2021-12-02, so no previous rotations
  # Standard rotation in 2023 cancelled, but it was kept for Alchemy, so it desynced from Standard
  # ANB always legal
  # Non-Standard-legal LTR is Arena-legal
  # https://mtg.fandom.com/wiki/Alchemy
  #
  # This is such a mess, I can't find historical data anywhere
  def rotation_schedule
    {
      "2024-08-02" => [ # rotation on BLB release?
        "anb",
        "woe", "ywoe",
        "lci", "ylci",
        "mkm", "ymkm",
        "otj", "yotj",
        "big",
        "blb", "yblb",
        "dsk", "ydsk",
        "fdn", # will likely have unusual rotation matching Standard
        "dft", "ydft",
        "tdm", "ytdm",
        "fin",
      ],
      "2023-08-02" => [
        "anb",
        "dmu", "ydmu",
        "bro", "ybro",
        "one", "yone",
        "mom", "mat",
        "ltr",
        "woe", "ywoe",
        "lci", "ylci",
        "mkm", "ymkm",
        "otj", "yotj",
        "big",
      ],
      "2022-09-09" => [
        "anb",
        "mid", "ymid", "vow", "neo", "yneo", "snc", "ysnc", "hbg",
        "dmu", "ydmu", "bro", "ybro", "one", "yone", "mom", "mat", "ltr", "woe", "ywoe", "lci", "ylci", "mkm", "ymkm", "otj", "big", "yotj",
      ],
      "2021-12-02" => [
        "anb",
        "znr", "khm", "stx", "afr",
        "mid", "ymid", "vow", "neo", "yneo", "snc", "ysnc", "hbg",
      ],
    }
  end

  def legality(card)
    card = card.main_front if card.is_a?(PhysicalCard)
    if !in_format?(card)
      nil
    else
      @ban_list.legality(card.name, @time)
    end
  end

  def in_format?(card)
    return false if card.has_alchemy
    card.printings.each do |printing|
      next if @time and printing.release_date > @time
      if @included_sets
        next unless @included_sets.include?(printing.set_code)
      else
        next if @excluded_sets.include?(printing.set_code)
      end
      return true
    end
    false
  end
end
