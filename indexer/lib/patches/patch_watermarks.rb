class PatchWatermarks < Patch
  def call
    each_printing do |card|
      watermark = card["watermark"]
      next unless watermark
      card["watermark"] = watermark
    end
  end
end
