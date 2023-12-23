# Flip cards keep primary side's mana cost and cmc for gameplay reasons
# But we don't want to actually show it on their title line

class PatchFlipCardManaCost < Patch
  def call
    mana_costs = {}

    each_printing do |card|
      if card["layout"] == "flip" and !card["secondary"]
        mana_costs[card["name"]] = card["mana"]
      end
    end

    each_printing do |card|
      if card["layout"] == "flip" and card["secondary"]
        other_side_name = card["names"][0]
        raise if other_side_name == card["name"]
        card["hide_mana_cost"] = true
        card["mana"] = mana_costs[other_side_name]
      end
    end
  end
end
