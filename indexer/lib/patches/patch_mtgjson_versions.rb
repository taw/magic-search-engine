# Cleanup differences between mtgjson v3 / v4 / v5

# This patch ended up as dumping ground for far too much random stuff

class PatchMtgjsonVersions < Patch
  # This can go away once mtgjson fixes their bugs
  def calculate_cmc(mana_cost)
    mana_cost.split(/[\{\}]+/).reject(&:empty?).map{|c|
      case c
      when /\A[WUBRGCS]\z/, /\A[WUBRG]\/[WUBRGP]\z/
        1
      when "X", "Y", "Z"
        0
      when "HW"
        0.5
      when /\d+/
        c.to_i
      else
        warn "Cannot calculate cmc of #{c} mana symbol"
        0
      end
    }.sum
  end

  def get_cmc(card)
    cmc = [card.delete("convertedManaCost"), card.delete("cmc")].compact.first
    fcmc = card.delete("faceConvertedManaCost")

    # mtgjson bug
    # https://github.com/mtgjson/mtgjson/issues/818
    if card["layout"] == "modal_dfc" or card["layout"] == "reversible_card"
      return calculate_cmc(card["manaCost"] || "")
    end

    if fcmc
      case card["layout"]
      when "split", "aftermath", "adventure"
        cmc = fcmc
      when "transform"
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

  def assign_number(card)
    @seen ||= {}
    set_code = card["set"]["official_code"]
    base_number = card["number"]
    counter = "a"
    while @seen[[set_code, base_number, counter]]
      counter.succ!
    end
    @seen[[set_code, base_number, counter]] = true
    card["number"] = "#{base_number}#{counter}"
  end

  def call
    # Delete all Alchemy cards
    delete_printing_if do |card|
      card["isRebalanced"]
    end

     each_printing do |card|
      if card["faceName"] and card["name"].include?("//")
        card["names"] = card["name"].split(" // ")
        card["name"] = card.delete("faceName")
      end
    end

    each_printing do |card|
      card["cmc"] = get_cmc(card)

      # I don't know of any better way of handling them
      # These are two separate cards as far as game rules are concerned
      if card["layout"] == "reversible_card"
        card["layout"] = "normal"
        card.delete "names"
        assign_number(card)
      end

      # This is text because of some X planeswalkers
      # It's more convenient for us to mix types
      card["loyalty"] = card["loyalty"].to_i if card["loyalty"] and card["loyalty"] =~ /\A\d+\z/

      # That got renamed a few times as DFCs are now of 3 types (transform, meld, mdfc)
      card["layout"] = "transform" if card["layout"] == "double-faced"

      # v4 uses []/"" while v3 just dropped such fields
      card.delete("supertypes") if card["supertypes"] == []
      card.delete("subtypes") if card["subtypes"] == []
      card.delete("rulings") if card["rulings"] == []
      card.delete("text") if card["text"] == ""
      card.delete("manaCost") if card["manaCost"] == ""
      card.delete("names") if card["names"] == []

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

      # This conflicts with isTextless in annoying ways
      if card["frame_effects"]
        card["frame_effects"].delete("textless")
      end

      # This is not quite set-based as there are Arena-specific fixed art cards
      # We used to have set-based logic, but it has no way of finding cards like znr/288†b
      card["digital"] = card.delete("isOnlineOnly")
      card["fullart"] = card.delete("isFullArt")
      card["oversized"] = card.delete("isOversized")
      # not sure what to do with it, isPromo flag, promoTypes, and our is:promo logic are all very different
      # so for now this is not used
      card["promo"] = card.delete("isPromo")
      card["spotlight"] = card.delete("isStorySpotlight")
      card["textless"] = card.delete("isTextless")
      card["timeshifted"] = card.delete("isTimeshifted")

      # OC21/OAFC are technically "display cards" not oversized
      # https://github.com/mtgjson/mtgjson/issues/815
      # O90P and OLEP are just mtgjson bug
      if %W[OC21 OAFC O90P OLEP].include?(card["set"]["official_code"])
        card["oversized"] = true
      end

      # mtgjson bug
      if card["set"]["official_code"] == "MOC" and (card["types"].include?("Plane") or card["types"].include?("Phenomenon"))
        card["oversized"] = true
      end

      # Moved in v5
      card["arena"] = true if card.delete("isArena") or card["availability"]&.delete("arena")
      card["paper"] = true if card.delete("isPaper") or card["availability"]&.delete("paper")
      card["mtgo"] = true if card.delete("isMtgo") or card["availability"]&.delete("mtgo")
      # shandalar data is incorrect in mtgjson, so we do not want it, we do our own calculations
      # dreamcast data is incorrect in mtgjson, there's no replacement on our side

      # This logic changed at some point, I like old logic better
      if card["oversized"] or %W[CEI CED 30A].include?(card["set"]["official_code"]) or card["border"] == "gold"
        card["nontournament"] = true
        card.delete("arena")
        card.delete("paper")
        card.delete("mtgo")
      end

      # Drop v3 layouts, use v4 layout here
      if card["layout"] == "plane" or card["layout"] == "phenomenon"
        card["layout"] = "planar"
      end

      if card["layout"] == "modal_dfc"
        card["layout"] = "modaldfc"
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

      if card["promoTypes"]
        card["promo_types"] = card["promoTypes"]
      end

      card["stamp"] = card.delete("securityStamp")

      if card["attractionLights"]
        card["attraction_lights"] = card["attractionLights"]
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
        card["flavor"] = card["flavor"].gsub(%[" —], %["\n—]).gsub(%[" "], %["\n"])
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

      card.delete("language") if card["language"] == "English"

      if card["finishes"].include?("etched")
        card["etched"] = true
      end
    end
  end

  def cleanup_unicode_punctuation(text)
    text.tr(%[‘’“”], %[''""])
  end
end
