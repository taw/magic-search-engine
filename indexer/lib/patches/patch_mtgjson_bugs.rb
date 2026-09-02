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

  # Oversized means "a bigger copy of a card that also exists at normal size".
  # mtgjson instead stamps it on every printing of the layouts that have no
  # normal size to be bigger than - planes, phenomena, schemes, and paper
  # vanguards - digital printings included, where size is not even a thing.
  # That makes the flag useless, so we drop it for those layouts entirely.
  # Matching the layout rather than the type catches the joke type lines,
  # pssc/sAnS mERcY ("pLAnE") and punk/That's Enough Slices ("Phenome-nom").
  INHERENTLY_BIG_LAYOUTS = %W[planar scheme vanguard].to_set.freeze

  INITIATIVE_TEXT = "Whenever one or more creatures a player controls deal " \
    "combat damage to you, that player takes the initiative.\n" \
    "Whenever you take the initiative and at the beginning of your upkeep, " \
    "venture into Undercity. (If you're in a dungeon, advance to the next " \
    "room. If you're not, enter Undercity. You can take the initiative even " \
    "if you already have it.)".freeze

  def call
    each_printing do |card|
      set_code = card["setCode"]

      if colors = FIN_ADVENTURE_COLORS[card["name"]]
        card["colors"] = colors
      end

      if OVERSIZED_SETS.include?(set_code)
        card["isOversized"] = true
      end

      if INHERENTLY_BIG_LAYOUTS.include?(card["layout"])
        card.delete("isOversized")
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

      # Scryfall mangled the Initiative face of CLB's dungeon token - "If you
      # te not, enter Undercity" for "If you're not, enter Undercity." - and
      # mtgjson copies whatever Scryfall says. PatchTokens has already split
      # the two faces by the time we get here, so this is the whole card.
      if card["name"] == "The Initiative" and set_code == "CLB"
        card["text"] = INITIATIVE_TEXT
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
