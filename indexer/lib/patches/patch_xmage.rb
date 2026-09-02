class PatchXmage < Patch
  # Known XMage typos / spoiler entries that never match a real card.
  # These are stable long-term problems, so we silence the warning for them
  # rather than reporting them on every index build.
  KNOWN_ISSUES = Set[
    ["atc", "Blinding Radiance"],
    ["atc", "Goblin Bruiser"],
    ["atc", "Ogre Painbringer"],
    ["atc", "Titanic Pelagosaur"],
    ["atc", "Treetop Recluse"],
    ["calc", "C-Pillar of the Paruns"],
  ]

  def xmage_cards_path
    Indexer::ROOT + "xmage_cards.txt"
  end

  def xmage_cards
    @xmage_cards ||= begin
      xmage_cards_path
        .readlines
        .map(&:chomp)
        .map{|line| line.split("\t",3)[0,2]}
        .map{|set, name| [set, normalize_name(name)] }
        .to_set
    end
  end

  # Normalize a card name so equivalent XMage / mtgjson spellings match:
  # - Decompose to NFD and drop combining marks, so any diacritic is stripped
  #   (the old hand-maintained tr list missed some, e.g. ï).
  # - Collapse ellipsis spacing, so XMage's "Foo . . ." matches mtgjson's "Foo..."
  #   without per-card overrides.
  # Both the card names and the XMage names are run through this.
  def normalize_name(str)
    str = str.unicode_normalize(:nfd).gsub(/\p{Mn}/, "")
    str.gsub(/\s*\.(?:\s*\.)+/) { |run| run.gsub(/\s+/, "") }
  end

  def card_names(card)
    names = card["names"] || [card["name"]]
    names.map{|n| normalize_name(n) }
  end

  def all_card_names
    @all_card_names ||= @cards.keys.map{|n| normalize_name(n)}
  end

  # Sets which are not out yet (st:preview). XMage routinely lists spoiled cards
  # before mtgjson has them, so an unmatched name in such a set is expected,
  # not a typo worth reporting.
  def preview_sets
    @preview_sets ||= @sets.select{|s| s["types"].include?("preview")}.map{|s| s["code"]}.to_set
  end

  def xmage_card_name_to_sets
    @xmage_card_name_to_sets ||= xmage_cards.group_by(&:last).transform_values{|c| c.map(&:first).uniq }
  end

  def call
    matched = Set[]

    each_printing do |card|
      names = card_names(card)
      set_code = card["set_code"]
      names.each do |name|
        if xmage_cards.include?([set_code, name])
          card["xmage"] = true
          matched << [set_code, name]
        end
      end
    end

    # XMage sets do not always correspond to mtgjson sets
    missed_cards = xmage_cards - matched
    # These are mostly missing unicode diacritics
    likely_typos = missed_cards.map(&:last) - all_card_names
    unless likely_typos.empty?
      likely_typos.each do |name|
        sets = xmage_card_name_to_sets[name]
        next if sets.all?{|set| KNOWN_ISSUES.include?([set, name]) or preview_sets.include?(set) }
        puts "Likely typo or spoiler card in XMage card list: #{name} (#{sets.join(", ")})"
      end
    end
  end
end
