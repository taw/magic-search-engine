# Flip cards keep primary side's mana cost and cmc for gameplay reasons
# But we don't want to actually show it on their title line

class PatchFlipCardManaCost < Patch
  def call
    each_printing do |card|
      if card["layout"] == "flip" and card["secondary"]
        card.delete("manaCost")
      end
    end
  end
end
