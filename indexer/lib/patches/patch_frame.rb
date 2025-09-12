# This used to do patch v3 vs v4 frame system
# but we just need to move on
class PatchFrame < Patch
  KNOWN_FRAMES = [
    "1993", "1997", "2003", "2015", "future"
  ]

  def call
    each_printing do |card|
      card["frame"] = card.delete("frameVersion")
      unless KNOWN_FRAMES.include?(card["frame"])
        card["frame"] = "2015"
        puts "Unknown frame version: #{fv.inspect}"
      end
    end
  end
end
