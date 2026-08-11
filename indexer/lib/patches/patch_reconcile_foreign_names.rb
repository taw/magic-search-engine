class PatchReconcileForeignNames < Patch
  # Japanese cards print furigana next to kanji, and some entries include them
  # like 事（じ）件（けん）現（げん）場（ば）. A few even got cut in half like 用心じん）棒、ラクドス.
  FURIGANA_RX = /（[ぁ-ゖァ-ヺー]*）|（[ぁ-ゖァ-ヺー]*|[ぁ-ゖァ-ヺー]*）/
  # Usually "x // y", but some data has "x/y", and SP//dr is not a split card
  SPLIT_RX = %r{ // |/}
  LIGATURES = {"œ" => "oe", "Œ" => "Oe", "æ" => "ae", "Æ" => "Ae"}.freeze

  def language_name_to_code
    @language_name_to_code ||= {
      "Chinese Simplified"  => "cs",
      "Chinese Traditional" => "ct",
      "French"              => "fr",
      "German"              => "de",
      "Italian"             => "it",
      "Japanese"            => "jp",
      "Korean"              => "kr",
      "Portuguese (Brazil)" => "pt",
      "Russian"             => "ru",
      "Spanish"             => "sp",
    }
  end

  # Gatherer's French pages for TDM showcase omens have their fields shifted by one,
  # so the back face got named after the front face's first line of rules text
  def known_wrong_names
    @known_wrong_names ||= Set[
      ["Absorb Essence", "fr", "Vol"],
      ["Charring Bite", "fr", "Vol"],
      ["Chilling Screech", "fr", "Vol"],
      ["Dusk Sight", "fr", "Vol, contact mortel"],
      ["Flush Out", "fr", "Vol, célérité"],
      ["Petty Revenge", "fr", "Vol"],
      ["Roost Seek", "fr", "Vol"],
    ]
  end

  def known_promo_language
    @known_promo_language ||= Set[
      "Ancient Greek",
      "Arabic",
      "Dwarvish",
      "Hebrew",
      "Latin",
      "Phyrexian",
      "Quenya",
      "Sanskrit",
    ]
  end

  def call
    each_card do |name, printings|
      ### Extract raw data
      # delete foreignNames while we're at it
      raw_data = extract_raw_data(printings)

      ### Reconcile data
      reconciled_data = reconcile(name, raw_data)

      ### Assign to all printings
      unless reconciled_data.empty?
        printings.each do |printing|
          printing["foreign_names"] = reconciled_data
        end
      end
    end
  end

  def extract_raw_data(printings)
    raw_data = {}
    printings.each do |printing|
      set_code = printing["set_code"]
      foreign_names_data = printing.delete("foreignNames") || printing.delete("foreignData") || next
      foreign_names_data.each do |e|
        language_code = language_name_to_code[e["language"]]
        unless language_code
          unless known_promo_language.include?(e["language"])
            warn "Unknown language: #{e["language"]}"
          end
          next
        end
        name = e["faceName"] || e["name"]
        unless name
          warn "Foreign data entry without name"
          next
        end
        foreign_name = name.gsub("&nbsp;", " ").tr("\u00a0", " ").sub(/ —\z/, "").delete("\ufeff")
        foreign_name = foreign_name.gsub(FURIGANA_RX, "") if language_code == "jp"
        next if foreign_name == ""
        raw_data[language_code] ||= {}
        raw_data[language_code][foreign_name] ||= []
        raw_data[language_code][foreign_name] << set_code
      end
    end
    raw_data
  end

  def reconcile(card_name, raw_data)
    result = {}

    raw_data.each do |language_code, names|
      names = names.reject{|name, _| known_wrong_names.include?([card_name, language_code, name])}
      names = drop_split_card_names(card_name, language_code, names)
      names = drop_english_names(card_name, names)
      # Every name we had for that language was junk
      next if names.empty?
      result[language_code] = reconcile_language(card_name, names)
    end

    result
  end

  # Foreign data for split cards often lists both halves as "x // y",
  # sometimes even the English "x // y", which is never what we want.
  def drop_split_card_names(card_name, language_code, names)
    names.reject do |name, _|
      parts = split_card_name(name) or next false
      # English name of the whole card
      next true if parts.all?{|part| english_card_name?(part)}
      # We already have the half we want
      next true if parts.any?{|part| names.key?(part)}
      # Or at least some name that isn't glued together
      next true if names.any?{|other, _| other != name and !split_card_name(other) and !english_card_name?(other)}
      warn "Only have both halves of split card #{card_name} [#{language_code}]: #{name}"
      false
    end
  end

  # Gatherer often lists the English name as a foreign name,
  # sometimes with fancy quotes like Kongming, “Sleeping Dragon”
  def drop_english_names(card_name, names)
    result = names.reject{|name, _| normalize_quotes(name) == card_name}
    # Plenty of cards genuinely have the same name in English and in other languages
    result.empty? ? names : result
  end

  def split_card_name(name)
    parts = name.split(SPLIT_RX, -1)
    return nil if parts.size < 2 or parts.any?(&:empty?)
    parts
  end

  def normalize_quotes(name)
    name.tr("“”", %[""])
  end

  def english_card_name?(name)
    @english_card_names ||= Set.new(@cards.keys)
    @english_card_names.include?(normalize_quotes(name))
  end

  # French really uses œ (cœur, œuf, rancœur), so OE is just mangled data.
  # It doesn't use æ at all, that's mangled data for ae in faerie or aether.
  # Otherwise the most capitalized name is the one that looks like a card name.
  def best_spelling(names)
    names.max_by{|name|
      [name.count("œŒ"), -name.count("æÆ"), name.chars.count{|c| c.upcase == c}]
    }
  end

  def reconcile_language(card_name, names)
    if names.size == 1
      [names.keys[0]]
    elsif names.keys.map{|n| n.gsub(/[œŒæÆ]/, LIGATURES).upcase}.uniq.size == 1
      # If names differ only by capitalization or ligatures, take the best spelling
      [best_spelling(names.keys)]
    elsif names.keys.any?{|n| n =~ /\(/}
      # Pointless A (A/B) for split cards
      short_names = names.keys.map{|x| x.sub(/\s*\(.*\)\z/, "")}.uniq - [card_name]
      if short_names.size != 1
        warn "Multiple short names, this is not supposed to happen: #{short_names.inspect}"
        short_names
      else
        [short_names[0]]
      end
    else
      # No idea, just include them all
      names.keys
    end
  end
end
