class PatchWatermarks < Patch
  def call
    patch_card do |card|
      watermark = card["watermark"]
      next unless watermark
      if %W[White Blue Black Red Green Colorless].include?(watermark)
        card.delete("watermark")
      else
        # FIXME: We need to be a lot smarter than this, Unstable watermarks have weird capitalization we need to preserve
        card["watermark"] = watermark.downcase
      end
    end
  end
end
