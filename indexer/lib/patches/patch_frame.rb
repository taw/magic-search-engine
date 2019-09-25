# We used to calculate it here,
# now just trust mtgjson v4
class PatchFrame < Patch
  def call
    each_printing do |card|
      fv = card.delete("frameVersion")
      case fv
      when "1993", "1997"
        card["frame"] = "old"
      when "2003"
        card["frame"] = "modern"
      when "2015"
        card["frame"] = "m15"
      when "future"
        card["frame"] = "future"
      else
        card["frame"] = "m15"
        puts "Unknown frame version: #{card["frame"].inspect}"
      end
    end
  end
end
