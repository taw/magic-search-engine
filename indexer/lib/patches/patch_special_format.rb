class PatchSpecialFormat < Patch
  # Cards that can only be played in one of Magic's special formats, and are legal
  # in no ordinary format at any date. Most of them are identified by a card type
  # that exists for exactly one variant:
  #
  #   Plane, Phenomenon (Planechase) - "Phenome-nom" and "pLAnE" are un-set spellings
  #   Scheme (Archenemy)
  #   Vanguard (Vanguard)
  #   Conspiracy (Conspiracy Draft)
  #   Hero (the Theros Hero's Path decks)
  #
  # Alchemy cards are deliberately not here. They're ordinary cards with an unusual
  # card pool, they are legal on Arena, and `alchemy` already says so.
  #
  # Attractions, stickers, contraptions and dungeons are not here either. They're
  # also not deck cards, but they are legal - Unfinity attractions and stickers are
  # Commander-legal today and were Legacy/Vintage/Pauper-legal until 2024-05-13, so
  # their legality has to come from the ban list, not from a flag.
  Types = %W[plane phenomenon phenome-nom scheme vanguard conspiracy hero].to_set.freeze

  # The Theros challenge decks (Face the Hydra, Battle the Horde, Defeat a God) are
  # the same idea without a card type to show for it - their 45 cards are ordinary
  # sorceries, artifacts and creatures, so only the set code identifies them.
  ChallengeDeckSets = %W[tbth tfth tdag].to_set.freeze

  def call
    each_card do |name, printings|
      special_format = printings.any?{|card| (card["types"] || []).any?{|type| Types.include?(type.downcase)}}
      special_format ||= printings.all?{|card| ChallengeDeckSets.include?(card["set_code"])}

      if special_format
        printings.each do |printing|
          printing["special_format"] = true
        end
      end
    end
  end
end
