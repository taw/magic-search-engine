class PatchConspiracyWatermarks < Patch
  def call
    each_printing do |card|
      next unless card["set_code"] == "cns" or card["set_code"] == "cn2"
      next unless draft?(card)
      warn "Already has a watermark #{card["watermark"]}" if card["watermark"]
      card["watermark"] = "draft"
    end
  end

  def draft?(card)
    types = card["types"] || []
    text = card["text"] || ""
    return true if types.include?("Conspiracy")
    return true if text.include?("as you draft it")
    return true if text.include?("you drafted")
    return true if text.include?("draft") and text.include?("face up")
    false
  end
end
