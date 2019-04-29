# Cleanup differences between mtgjson v3 and v4

class PatchMtgjsonVersions < Patch
  def get_cmc(card)
    cmc = [card.delete("convertedManaCost"), card.delete("cmc")].compact.first
    fcmc = card.delete("faceConvertedManaCost")

    if fcmc
      if card["layout"] == "split" or card["layout"] == "aftermath"
        cmc = fcmc
      elsif card["layout"] == "flip" or card["layout"] == "transform"
        # ignore because
        # https://github.com/mtgjson/mtgjson/issues/294
      elsif cmc != fcmc
        warn "#{card["layout"]} #{card["name"]} has fcmc #{fcmc} != cmc #{cmc}"
      end
    end

    cmc = cmc.to_i if cmc.to_i == cmc
    cmc
  end

  def call
    each_set do |set|
      set["type"] = set["type"].gsub("_", " ")
      if set["official_code"] == "BBD"
        set["type"] = "two-headed giant"
      end
    end

    # drop all tokens
    @cards.delete_if { |card| card["types"] =~ /Token/ }

    each_printing do |card|
      card_is_v4 = !!card["multiverseId"]

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

      if card["flavorText"]
        card["flavor"] = card.delete("flavorText")
      end

      if card["borderColor"]
        card["border"] = card.delete("borderColor")
      end

      # Renamed in v4
      card["multiverseid"] ||= card.delete("multiverseId")
      if card.has_key?("isReserved")
        if card.delete("isReserved")
          card["reserved"] = true
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

      # Flavor text quick fix because v4 doesn't have newlines
      if card["flavor"]
        card["flavor"] = card["flavor"].gsub(%Q[" —], %Q["\n—]).gsub(%Q[" "], %Q["\n"])
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

      # Rulings ordering is arbitrarily different, just pick canonical ordering
      # (do it after Unicode normalization)
      # Just not now as it messes up witsh diffs
      # if card["rulings"]
      #   card["rulings"] = card["rulings"].sort_by{|ruling|
      #     [ruling["date"], ruling["text"]]
      #   }
      # end
    end

    # Remove sets without cards (v4 token only sets)
    nonempty_sets = @cards.values.flatten(1).map{|x| x["set"] }.to_set
    @sets.delete_if{|s| !nonempty_sets.include?(s) }
  end

  def cleanup_unicode_punctuation(text)
    text.tr(%Q[‘’“”], %Q[''""])
  end
end
