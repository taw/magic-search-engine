class PatchXmage < Patch
  def xmage_cards_path
    Pathname(__dir__) + "../../../data/xmage_cards.txt"
  end

  def xmage_cards
    @xmage_cards ||= begin
      xmage_cards_path
        .readlines
        .map(&:chomp)
        .map{|line| line.split("\t",3)[0,2]}
        .to_set
    end
  end

  def strip_accents(str)
    str.tr("äàáââééíöóûûúÉ", "aaaaaeeioouuuE")
  end

  def card_names(card)
    names = card["names"] || [card["name"]]
    names.map{|n| strip_accents(n) }
  end

  def all_card_names
    @all_card_names ||= @cards.keys.map{|n| strip_accents(n)}
  end

  def xmage_card_name_to_sets
    @xmage_card_name_to_sets ||= xmage_cards.group_by(&:last).transform_values{ _1.map(&:first).uniq }
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
        puts "Likely typo or spoiler card in XMage card list: #{name} (#{xmage_card_name_to_sets[name].join(", ")})"
      end
    end
  end
end
