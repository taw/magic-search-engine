class PatchSecondary < Patch
  def call
    each_printing do |card|
      next unless card["names"]
      # https://github.com/mtgjson/mtgjson/issues/227
      if card["name"] == "B.F.M. (Big Furry Monster)" or card["name"] == "B.F.M. (Big Furry Monster, Right Side)"
        # just give up on this one
      elsif card["layout"] == "split"
        # All primary
      elsif card["layout"] == "transform" or card["layout"] == "modaldfc"
        if card["number"] =~ /a\z/i
          # Primary
        elsif card["number"] =~ /b\z/i
          card["secondary"] = true
        elsif card["names"].index(card["name"]) == 0
          # Primary
        elsif card["names"].index(card["name"]) == 1
          card["secondary"] = true
        else
          warn "No idea if DFC #{card["name"]} is primary or secondary"
        end
      elsif card["layout"] == "flip" or card["layout"] == "aftermath" or card["layout"] == "adventure"
        raise unless card["number"] =~ /[ab]\z/i
        card["secondary"] = true if card["number"] =~ /b\z/i
      elsif card["layout"] == "meld"
        # leave it for PatchMeld
      else
        raise "Unknown multipart card layout: #{card["layout"]} for #{card["name"]}"
      end
    end
  end
end
