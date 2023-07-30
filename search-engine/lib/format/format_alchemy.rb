class FormatAlchemy < FormatStandard
  def format_pretty_name
    "Alchemy"
  end

  # Format announced 2021-12-02, so no previous rotations
  # Rotation in 2023 cancelled
  # ANB always legal
  # Non-Standard-legal LTR is Arena-legal
  # https://mtg.fandom.com/wiki/Alchemy
  def rotation_schedule
    {
      "2022-09-09" => [
        "anb",
        "mid", "ymid", "vow", "neo", "yneo", "snc", "ysnc", "hbg",
        "dmu", "ydmu", "bro", "ybro", "one", "yone", "mom", "mat", "ltr",
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
