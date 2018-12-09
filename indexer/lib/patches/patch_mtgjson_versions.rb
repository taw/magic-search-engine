# Cleanup differences between mtgjson v3 and v4

class PatchMtgjsonVersions < Patch
  def get_cmc(*data)
    cmc = data.compact.first
    cmc = cmc.to_i if cmc.to_i == cmc
    cmc
  end

  def call
    each_set do |set|
      set["type"] = set["type"].gsub("_", " ")
    end

    # drop all tokens
    @cards.delete_if { |card| card["types"] =~ /Token/ }

    each_printing do |card|
      card["cmc"] = get_cmc(
        card.delete("faceConvertedManaCost"),
        card.delete("convertedManaCost"),
        card.delete("cmc"),
      )

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

      # Renamed in v4
      card["multiverseid"] ||= card.delete("multiverseId")

      # Unicode vs ASCII
      if card["rulings"]
        card["rulings"].each do |ruling|
          ruling["text"] = cleanup_unicode_punctuation(ruling["text"])
        end
      end
      if card["text"]
        card["text"] = cleanup_unicode_punctuation(card["text"])
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
  end

  def cleanup_unicode_punctuation(text)
    text.tr(%Q[’“”], %Q['""])
  end
end
