class FormatAlchemy < FormatStandard
  def format_pretty_name
    "Alchemy"
  end

  # Announced 2021-12-02, went live with the December 2021 Arena update together with Alchemy: Innistrad.
  # rotation_schedule below uses the announcement date instead, as that's when the card pool was declared.
  # https://magic.wizards.com/en/news/mtg-arena/introducing-alchemy-new-way-play-mtg-arena-2021-12-02
  def format_start_date
    "2021-12-09"
  end

  # Format announced 2021-12-02, so no previous rotations
  # Standard rotation in 2023 cancelled, but it was kept for Alchemy, so it desynced from Standard
  # ANB always legal
  # Non-Standard-legal LTR is Arena-legal
  # https://mtg.fandom.com/wiki/Alchemy
  #
  # This is such a mess, I can't find historical data anywhere
  ROTATION_SCHEDULE = {
    "2025-08-01" => [ # rotation on EOE release
      "anb",
      "blb", "yblb",
      "dsk", "ydsk",
      "fdn", # will likely have unusual rotation matching Standard
      "dft", "ydft",
      "tdm", "ytdm",
      "fin",
      "eoe", "yeoe",
      "spm",
      "tla",
      "ecl", "yecl",
      "tmt",
      "sos", "ysos",
      "msh",
      "hob",
    ],
    "2024-08-02" => [ # rotation on BLB release?
      "anb",
      "woe", "ywoe",
      "lci", "ylci",
      "mkm", "ymkm",
      "otj", "big", "yotj",
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
      "otj", "big", "yotj",
    ],
    "2022-09-09" => [
      "anb",
      "mid", "vow", "ymid", "neo", "yneo", "snc", "ysnc", "hbg",
      "dmu", "ydmu", "bro", "ybro", "one", "yone", "mom", "mat", "ltr", "woe", "ywoe", "lci", "ylci", "mkm", "ymkm", "otj", "big", "yotj",
    ],
    "2021-12-02" => [
      "anb",
      "znr", "khm", "stx", "afr",
      "mid", "vow", "ymid", "neo", "yneo", "snc", "ysnc", "hbg",
    ],
  }.map{|rotation_time, rotation_sets| [Date.parse(rotation_time), rotation_sets.freeze].freeze}.freeze

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
