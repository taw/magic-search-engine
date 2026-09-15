# Arena reverted every rebalanced version of a tabletop card to its original
# printing on 2026-09-22, so the A- cards simply stopped existing:
# https://magic.wizards.com/en/news/mtg-arena/state-of-the-formats-2026
#
# mtgjson only keeps a card for as long as it is rebalanced - a reverted one is
# dropped from its data, which is what happened to A-Omnath and A-Teferi years
# ago - so this is where the whole remaining batch of them goes.
#
# Digital-only Alchemy cards are untouched. They stay on Arena, and the ones
# which were rebalanced were rebalanced in place, so mtgjson never gave them an
# A- name of their own to drop.
class PatchDropRebalanced < Patch
  def call
    delete_printing_if do |card|
      # A-Town is a joke card, the A- is part of the name, not a rebalance
      card["isRebalanced"] and card["name"] != "A-Town"
    end

    each_printing do |card|
      card.delete("isRebalanced")
    end
  end
end
