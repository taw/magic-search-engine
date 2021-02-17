class PatchShowcase < Patch
  def call
    patch_set(
      "iko",
      1..274,
      276..363,
      "common" => ["C3", "C2", "C1"],
      "uncommon" => ["U3", "U2", "U1"],
      "rare" => ["R6", "R4", "R2"],
      "mythic" => ["R3", "R2", "R1"]
    )
    patch_iko_lands
  end

  def patch_iko_lands
    # each has 3 variants, so totals are actually 50:50
    l2 = Set[
      "Forest",
      "Island",
      "Mountain",
      "Plains",
      "Swamp",
    ]
    l3 = [
      "Bloodfell Caves",
      "Blossoming Sands",
      "Dismal Backwater",
      "Jungle Hollow",
      "Rugged Highlands",
      "Scoured Barrens",
      "Swiftwater Cliffs",
      "Thornwood Falls",
      "Tranquil Cove",
      "Wind-Scarred Crag",
    ]
    each_printing do |card|
      next unless card["set_code"] == "iko"
      if l2.include?(card["name"])
        card["print_sheet"] = "L2"
      end
      if l3.include?(card["name"])
        card["print_sheet"] = "L3"
      end
    end
  end

  def patch_set(set_code, boring_numbers, fancy_numbers, sheets)
    cards_in_set = Set[]

    each_printing do |card|
      next unless card["set_code"] == set_code
      cards_in_set << card
    end

    sheets.each do |rarity, (sn, sb, sf)|
      cards_in_rarity = cards_in_set.select{|c| c["rarity"] == rarity and not c["exclude_from_boosters"]}
      fancy_cards = cards_in_rarity.select{|c| fancy_numbers.include? c["number"].to_i }
      fancy_names = fancy_cards.map{|c| c["name"]}.to_set

      cards_in_rarity.each do |c|
        number_i = c["number"].to_i
        if fancy_numbers.include?(number_i)
          c["print_sheet"] = sf
        elsif boring_numbers.include?(number_i)
          if fancy_names.include?(c["name"])
            c["print_sheet"] = sb
          else
            c["print_sheet"] = sn
          end
        end
      end
    end
  end
end
