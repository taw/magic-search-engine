class PatchReconcileForeignNames < Patch
  # Japanese cards print furigana next to kanji, and some entries include them
  # like 事（じ）件（けん）現（げん）場（ば）. A few even got cut in half like 用心じん）棒、ラクドス.
  FURIGANA_RX = /（[ぁ-ゖァ-ヺー]*）|（[ぁ-ゖァ-ヺー]*|[ぁ-ゖァ-ヺー]*）/

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
      names = drop_split_card_names(card_name, language_code, names)
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
      parts = name.split(" // ")
      next false if parts.size < 2
      # English name of the whole card
      next true if parts.all?{|part| english_card_name?(part)}
      # We already have the half we want
      next true if parts.any?{|part| names.key?(part)}
      warn "Only have both halves of split card #{card_name} [#{language_code}]: #{name}"
      false
    end
  end

  def english_card_name?(name)
    @english_card_names ||= Set.new(@cards.keys)
    @english_card_names.include?(name)
  end

  def reconcile_language(card_name, names)
    if names.size == 1
      [names.keys[0]]
    elsif names.size == 2 and names.include?(card_name)
      # English names are often mistakenly listed by Gatherer
      [(names.keys - [card_name])[0]]
    elsif names.keys.map(&:upcase).uniq.size == 1
      # If names differ only by capitalization, take the most capitalized name
      [names.keys.max_by{|s|
        s.chars.count{|c| c.upcase == c}
      }]
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
