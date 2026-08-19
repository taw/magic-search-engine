# Straightforward mtgjson data bugs, patched on top of the raw mtgjson fields
# before PatchMtgjsonFields renames them.
#
# Anything that needs a lot of code (reversible cards) or that fits an existing
# patch (spellbook contents, meld parts) lives there instead.

class PatchMtgjsonBugs < Patch
  # Adventure back sides of the Final Fantasy lands are colorless in mtgjson
  # https://github.com/mtgjson/mtgjson/issues/1335
  # The mana costs got fixed, the colors did not.
  FIN_ADVENTURE_COLORS = {
    "Faith & Grief"  => ["W"],
    "Overture"       => ["U"],
    "Reactor Raid"   => ["B"],
    "Mage Siege"     => ["R"],
    "Lasting Fayth"  => ["G"],
  }.freeze

  # OC21/OAFC are technically "display cards" not oversized
  # https://github.com/mtgjson/mtgjson/issues/815
  # O90P and OLEP are just mtgjson bug
  OVERSIZED_SETS = %W[OC21 OAFC O90P OLEP].freeze

  def call
    each_printing do |card|
      set_code = card["setCode"]

      if colors = FIN_ADVENTURE_COLORS[card["name"]]
        card["colors"] = colors
      end

      if OVERSIZED_SETS.include?(set_code)
        card["isOversized"] = true
      end

      if set_code == "MOC" and (card["types"].include?("Plane") or card["types"].include?("Phenomenon"))
        card["isOversized"] = true
      end

      # MBC is a paper set, but a few cards are marked as arena-only
      if set_code == "MBC"
        card["availability"] = ["paper"]
        card.delete("isOnlineOnly")
      end

      # Numbering conflict in mtgjson data
      # They have RZ15 (which we turn into RZ15a/RZ15b) and RZ15b
      # We need to move that RZ15b away to something else
      # And same shit for CU12a, CU12b
      if set_code == "UNK"
        case card["number"]
        when "RZ15b" then card["number"] = "RZ15x"
        when "CU12a" then card["number"] = "CU12x"
        when "CU12b" then card["number"] = "CU12y"
        end
      end

      # First https://github.com/mtgjson/mtgjson/issues/1094 but it keeps coming back
      # so a permanent fix here
      if card["subtypes"]&.include?("Saga") and card["layout"] == "normal"
        card["layout"] = "saga"
      end

      # Some cmb1/cmb2 cards not updated yet
      if card["types"].include?("Tribal")
        card["types"] = card["types"].map{|t| t == "Tribal" ? "Kindred" : t}
      end

      if card["rulings"]
        rulings_dates = card["rulings"].map{|x| x["date"] }
        unless rulings_dates.sort == rulings_dates
          warn "Rulings for #{card["name"]} in #{card["set"]["name"]} not in order"
        end
      end
    end
  end
end
