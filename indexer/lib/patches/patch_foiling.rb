class PatchFoiling < Patch
  def calculate_mtgjson_foiling
    # Translate v4 foiling into system we use
    each_printing do |card|
      if card["set"]["v4"]
        case [card["hasNonFoil"], card["hasFoil"]]
        when [true, true]
          card["mtgjson_foiling"] = "both"
        when [true, false]
          card["mtgjson_foiling"] = "nonfoil"
        when [false, true]
          card["mtgjson_foiling"] = "foilonly"
        else
          warn "Bad foiling information for #{name} in #{set_code}"
        end
      end
      card.delete "hasFoil"
      card.delete "hasNonFoil"
    end
  end

  def calculate_indexer_foiling
    each_printing do |card|
      name = card["name"]
      set_code = card["set_code"]
      set = card["set"]
      number = card["number"]

      case set["type"]
      when "masters", "spellbook", "two-headed giant", "reprint"
        card["indexer_foiling"] = "both"
      when "from the vault", "premium deck", "masterpiece"
        card["indexer_foiling"] = "foilonly"
      when "core", "expansion"
        if set["release_date"] < "1999-02-15" or set_code == "6ed"
          card["indexer_foiling"] = "nonfoil"
        else
          if card["exclude_from_boosters"]
            # it's for precons to figure it out, not for us
            # There will be usually 1 foilonly planeswalker +
            # a bunch of nonfoil pw cards there, but no point duplicating that list here

            # TODO: temporary v3 hacks
            if number =~ /★/ and %W[pls].include?(set_code)
              card["indexer_foiling"] = "foilonly"
            end

            if set_code == "bfz" or set_code == "ogw"
              card["indexer_foiling"] = "nonfoil"
            end
          else
            card["indexer_foiling"] = "both"
          end
        end
      end

      # By set
      case set_code
      when "ced", "cei"
        card["indexer_foiling"] = "nonfoil"
      when "cm1", "p15a", "psus", "psum", "pwpn", "p2hg", "pgpx", "pwcq", "plpa", "pjgp", "ppro", "pgtw", "pwor", "prel", "pfnm", "pwos", "ppre"
        card["indexer_foiling"] = "foilonly"
      when "ced", "cei", "chr", "pgru", "palp", "pdrc", "pelp", "plgm", "ugin", "pcel", "van", "s99", "mgb"
        card["indexer_foiling"] = "nonfoil"
      when "ugl"
        card["indexer_foiling"] = "nonfoil"
      when "unh", "cn2"
        card["indexer_foiling"] = "both"
      when "ust", "tsb", "cns"
        card["indexer_foiling"] = "both"
      when "e02", "w16", "w17", "rqs", "itp", "cst", "s00"
        card["indexer_foiling"] = "nonfoil" # was: "precon"
      when "cp1", "cp2", "cp3"
        card["indexer_foiling"] = "foilonly"
      when "por", "p02", "ptk", "ppod"
        card["indexer_foiling"] = "nonfoil"
      when "8ed", "9ed"
        if number =~ /\AS/
          card["indexer_foiling"] = "nonfoil"
        else
          card["indexer_foiling"] = "both"
        end
      end

      # Special cards
      if set_code == "m19" and name == "Nexus of Fate"
        card["indexer_foiling"] = "foilonly"
      elsif set_code == "dom" and name == "Firesong and Sunspeaker"
        card["indexer_foiling"] = "foilonly"
      elsif set_code == "grn" and name == "Impervious Greatwurm"
        card["indexer_foiling"] = "foilonly"
      elsif set_code == "grn" and card["supertypes"] == ["Basic"]
        card["indexer_foiling"] = "both"
      elsif set_code == "rna" and name == "The Haunt of Hightower"
        card["indexer_foiling"] = "foilonly"
      elsif set_code == "rna" and card["supertypes"] == ["Basic"]
        card["indexer_foiling"] = "both"
      elsif set_code == "war" and name == "Tezzeret, Master of the Bridge"
        card["indexer_foiling"] = "foilonly"
      elsif set_code == "ori" and number.to_i >= 273
        # Deck Builder's Toolkit (Magic Origins Edition)
        card["indexer_foiling"] = "nonfoil"
      elsif set_code == "akh"
        # There's boosters, precons, and also Deck Builder's Toolkit
        # These are Deck Builder's Toolkit only
        if ["Forsaken Sanctuary", "Meandering River", "Timber Gorge", "Tranquil Expanse"].include?(name)
          card["indexer_foiling"] = "nonfoil"
        end
      elsif set_code == "unh" and name == "Super Secret Tech"
        card["indexer_foiling"] = "foilonly"
      elsif set_code == "cn2" and name == "Kaya, Ghost Assassin"
        if number == "75"
          card["indexer_foiling"] = "nonfoil"
        else
          card["indexer_foiling"] = "foilonly"
        end
      elsif set_code == "bbd" and name == "Rowan Kenrith"
        if number == "2"
          card["indexer_foiling"] = "nonfoil"
        else
          card["indexer_foiling"] = "foilonly"
        end
      elsif set_code == "bbd" and name == "Will Kenrith"
        if number == "1"
          card["indexer_foiling"] = "nonfoil"
        else
          card["indexer_foiling"] = "foilonly"
        end
      elsif set_code == "hop" and name == "Tazeem"
        card["indexer_foiling"] = "nonfoil"
      elsif set_code == "pc2" and name == "Stairs to Infinity"
        card["indexer_foiling"] = "nonfoil"
      elsif set_code == "pca" or set_code == "opca" or set_code == "parc"
        card["indexer_foiling"] = "nonfoil"
      elsif set_code == "ppre"
        if ["Dirtcowl Wurm", "Revenant", "Monstrous Hound"].include?(name)
          card["indexer_foiling"] = "nonfoil"
        end
      elsif set_code == "s00"
        if name == "Rhox"
          card["indexer_foiling"] = "foilonly"
        elsif ["Armored Pegasus", "Python", "Spined Wurm", "Stone Rain"].include?(name)
          card["indexer_foiling"] = "nonfoil"
        end
      end
    end
  end

  def reconcile_foiling_data
    each_printing do |card|
      indexer_foiling = card.delete("indexer_foiling")
      mtgjson_foiling = card.delete("mtgjson_foiling")
      name = "#{card["name"]} [#{card["set_code"]}:#{card["number"]}]"

      # Too many warnigs
      if card["set_code"] == "10e"
        indexer_foiling = nil
      end

      if mtgjson_foiling.nil?
        if indexer_foiling.nil?
          warn "Foiling for #{name} missing, assuming foilboth"
          card["foiling"] = "both"
        else
          card["foiling"] = indexer_foiling
        end
      elsif indexer_foiling.nil?
        card["foiling"] = mtgjson_foiling
      elsif mtgjson_foiling == indexer_foiling
        card["foiling"] = indexer_foiling
      else
        warn "Foiling for #{name} mismatching, m:#{mtgjson_foiling} i:#{indexer_foiling}"
        card["foiling"] = mtgjson_foiling
      end
    end
  end

  def call
    calculate_mtgjson_foiling
    calculate_indexer_foiling
    reconcile_foiling_data
  end
end
