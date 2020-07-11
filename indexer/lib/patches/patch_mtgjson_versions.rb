# Cleanup differences between mtgjson v3 / v4 / v5

# This patch ended up as dumping ground for far too much random stuff

class PatchMtgjsonVersions < Patch
  def get_cmc(card)
    cmc = [card.delete("convertedManaCost"), card.delete("cmc")].compact.first
    fcmc = card.delete("faceConvertedManaCost")

    if fcmc
      case card["layout"]
      when "split", "aftermath", "adventure"
        cmc = fcmc
      when "flip", "transform"
        # ignore because
        # https://github.com/mtgjson/mtgjson/issues/294
      else
        if cmc != fcmc
          warn "#{card["layout"]} #{card["name"]} has fcmc #{fcmc} != cmc #{cmc}"
        end
      end
    end

    cmc = cmc.to_i if cmc.to_i == cmc
    cmc
  end

  def call
    each_printing do |card|
      if card["faceName"] and card["name"].include?("//")
        card["names"] = card["name"].split(" // ")
        card["name"] = card.delete("faceName")
      end

      if card["layout"] == "meld" and not card["names"]
        case card["name"]
        when "Brisela, Voice of Nightmares"
          card["names"] = [
            "Bruna, the Fading Light",
            "Gisela, the Broken Blade",
            "Brisela, Voice of Nightmares",
          ]
        when "Chittering Host"
          card["names"] = [
            "Graf Rats",
            "Midnight Scavengers",
            "Chittering Host",
          ]
        when "Hanweir, the Writhing Township"
          card["names"] = [
            "Hanweir Battlements",
            "Hanweir Garrison",
            "Hanweir, the Writhing Township",
          ]
        else
          raise "No front names for melded card: #{card["name"]}"
        end
      end

      # Someone should investigate if this is true
      # This also applies to PSOI
      if card["name"] == "Tamiyo's Journal" and card["set"]["official_code"] == "SOI"
        card["hasFoil"] = true
        card["hasNonFoil"] = true
      end
    end

    each_printing do |card|
      card["cmc"] = get_cmc(card)

      # This is text because of some X planeswalkers
      # It's more convenient for us to mix types
      card["loyalty"] = card["loyalty"].to_i if card["loyalty"] and card["loyalty"] =~ /\A\d+\z/

      # That got renamed. New version probably makes more sense,
      # as meld is also "double-faced"
      card["layout"] = "double-faced" if card["layout"] == "transform"

      # v4 uses []/"" while v3 just dropped such fields
      card.delete("supertypes") if card["supertypes"] == []
      card.delete("subtypes") if card["subtypes"] == []
      card.delete("rulings") if card["rulings"] == []
      card.delete("text") if card["text"] == ""
      card.delete("manaCost") if card["manaCost"] == ""
      card.delete("names") if card["names"] == []

      # Moved in v5
      card["arena"] = true if card.delete("isArena") or card["availability"]&.delete("arena")
      card["paper"] = true if card.delete("isPaper") or card["availability"]&.delete("paper")
      card["mtgo"] = true if card.delete("isMtgo") or card["availability"]&.delete("mtgo")

      if card["frameVersion"] == "future"
        card["timeshifted"] = true
      end

      if card["flavorText"]
        card["flavor"] = card.delete("flavorText")
      end

      if card["borderColor"]
        card["border"] = card.delete("borderColor")
      end

      if card["frameEffects"]
        card["frame_effects"] = card.delete("frameEffects")
      elsif card["frameEffect"]
        card["frame_effects"] = [card.delete("frameEffect")]
      end

      card["oversized"] = card.delete("isOversized")
      card["spotlight"] = card.delete("isStorySpotlight")
      card["fullart"] = card.delete("isFullArt")
      card["textless"] = card.delete("isTextless")

      # Drop v3 layouts, use v4 layout here
      if card["layout"] == "plane" or card["layout"] == "phenomenon"
        card["layout"] = "planar"
      end

      # Renamed in v4, then moved in v5. v5 makes it a String
      card["multiverseid"] ||= card.delete("multiverseId")
      card["multiverseid"] ||= card["identifiers"]&.delete("multiverseId")
      card["multiverseid"] = card["multiverseid"].to_i if card["multiverseid"].is_a?(String) and card["multiverseid"] =~ /\A\d+\z/

      if card.has_key?("isReserved")
        if card.delete("isReserved")
          card["reserved"] = true
        end
      end

      if card.has_key?("isBuyABox")
        if card.delete("isBuyABox")
          card["buyabox"] = true
        end
      end

      if card["promoTypes"]&.include?("buyabox")
        card["promoTypes"].delete("buyabox")
        card["buyabox"] = true
      end

      # Unicode vs ASCII
      if card["rulings"]
        card["rulings"].each do |ruling|
          ruling["text"] = cleanup_unicode_punctuation(ruling["text"])
        end
      end
      if card["text"]
        card["text"] = cleanup_unicode_punctuation(card["text"])
      end
      if card["artist"]
        card["artist"] = cleanup_unicode_punctuation(card["artist"])
      end

      # Flavor text quick fix because v4 doesn't have newlines
      if card["flavor"]
        card["flavor"] = card["flavor"].gsub(%Q[" —], %Q["\n—]).gsub(%Q[" "], %Q["\n"])
      end

      # mtgjson started using * to indicate italics? annoying
      if card["flavor"]
        card["flavor"] = card["flavor"].gsub("*", "")
      end

      if card["flavorName"]
        card["flavor_name"] = card.delete("flavorName")
      end

      if card["rulings"]
        rulings_dates = card["rulings"].map{|x| x["date"] }
        unless rulings_dates.sort == rulings_dates
          warn "Rulings for #{card["name"]} in #{card["set"]["name"]} not in order"
        end
      end

      if card["keywords"]
        card["keywords"] = card["keywords"].map(&:downcase)
      end

      # At least for now:
      # "123a" but "U123"
      if card["number"]
        card["number"] = card["number"].sub(/(\D+)\z/){ $1.downcase }
      end

      # Weird Escape formatting, make it match other similar abilities
      if card["text"] =~ /^Escape—/
        card["text"] = card["text"].gsub(/^Escape—/, "Escape — ")
      end
    end

    # Remove sets without cards (v4 token only sets)
    nonempty_sets = @cards.values.flatten(1).map{|x| x["set"] }.to_set
    @sets.delete_if{|s| !nonempty_sets.include?(s) }
  end

  def cleanup_unicode_punctuation(text)
    text.tr(%Q[‘’“”], %Q[''""])
  end
end
