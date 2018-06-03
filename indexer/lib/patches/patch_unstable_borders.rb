class PatchUnstableBorders < Patch
  def call
    patch_card do |card|
      next unless card["set_code"] == "ust"
      name = card["name"]
      supertypes = (card["supertypes"] || [])
      subtypes = (card["subtypes"] || [])

      if name == "Steamflogger Boss"
        card["border"] = "black"
      end

      if supertypes.include?("Basic") or subtypes.include?("Contraption")
        card["border"] = "none"
      end
    end
  end
end
