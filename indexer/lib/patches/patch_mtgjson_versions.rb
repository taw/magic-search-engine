# Cleanup differences between mtgjson v3 and v4

class PatchMtgjsonVersions < Patch
  def call
    each_set do |set|
      set["type"] = set["type"].gsub("_", " ")
    end

    each_printing do |card|
      # renamed cmc field and made it a float (for unsets presumably)
      if card["convertedManaCost"] and not card["cmc"]
        cmc = card.delete("convertedManaCost")
        cmc = cmc.to_i if cmc.to_i == cmc
        card["cmc"] = cmc
      end

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
      if card["rulings"]
        card["rulings"] = card["rulings"].sort_by{|ruling|
          [ruling["date"], ruling["text"]]
        }
      end
    end
  end

  def cleanup_unicode_punctuation(text)
    text.tr(%Q[’“”], %Q['""])
  end
end
