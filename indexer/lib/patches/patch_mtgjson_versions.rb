# Cleanup differences between mtgjson v3 and v4

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
    each_set do |set|
      # mtgjson v4 decided to make releaseDate per-set
      # that leads to need for a lot of BS adjustments

      # I trust unsourced mtg wiki claim here more
      # since this is definitely wrong
      # https://mtg.gamepedia.com/Duel_Decks:_Mirrodin_Pure_vs._New_Phyrexia
      case set["official_code"]
      when "TD2"
        set["releaseDate"] = "2013-01-11"
      # Some random tweaks
      when "C18"
        set["releaseDate"] = "2018-08-10"
      when "DDT"
        set["releaseDate"] = "2017-11-10"
      when "PPRO"
        set["releaseDate"] = "2018-01-01"
      when "P02"
        set["releaseDate"] = "1998-06-24"
      when "PZ2"
        set["releaseDate"] = "2018-08-10"
      when "PRM"
        set["releaseDate"] = "2018-08-10"
      end
    end

    # Someone should investigate if this is true
    # This also applies to PSOI
    each_printing do |card|
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

      card["arena"] = true if card.delete("isArena")
      card["paper"] = true if card.delete("isPaper")
      card["mtgo"] = true if card.delete("isMtgo")

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

      # Renamed in v4
      card["multiverseid"] ||= card.delete("multiverseId")
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

      if card["rulings"]
        rulings_dates = card["rulings"].map{|x| x["date"] }
        unless rulings_dates.sort == rulings_dates
          warn "Rulings for #{card["name"]} in #{card["set"]["name"]} not in order"
        end
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
