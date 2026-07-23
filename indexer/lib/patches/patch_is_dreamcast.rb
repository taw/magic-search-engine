class PatchIsDreamcast < Patch
  # The Japan-only Dreamcast game (Sega, 2001-06-28) had a fixed pool of 354 cards:
  # * every card of 6th Edition - 335 of them, counting each basic land once
  # * 9 cards reprinted from older sets, none of which were in 6th Edition
  # * 10 cards exclusive to the game, released on paper much later as PSDG
  #
  # mtgjson's "dreamcast" availability only covers the 10 PSDG cards,
  # not the pool the game was actually played with, so we do our own calculations.
  #
  # Sources for the pool:
  # * http://mtgwiki.com/wiki/ドリームキャスト版マジック：ザ・ギャザリング
  # * http://www.jfkmagic.sakura.ne.jp/mtg/DC_list.txt (Wayback only)
  #   translated from Magic Rarities and Dreamcast Magazine vol.41
  # English sources claiming the game used Alliances and Tempest cards are
  # counting just two of the nine, and miss the rest.

  DREAMCAST_SETS = %W[6ed psdg]

  # Neither source says which printing the game took art and wording from,
  # so we flag the most recent printing in a regular set before the game shipped.
  DREAMCAST_EXTRA_CARDS = {
    "5ed" => ["Bad Moon", "Nevinyrral's Disk", "Winter Orb"],
    "all" => ["Thawing Glaciers"],
    "ice" => ["Icy Manipulator", "Swords to Plowshares"],
    "sth" => ["Mox Diamond"],
    "tmp" => ["Death Pits of Rath", "Tradewind Rider"],
  }

  def call
    matched = Set[]

    each_printing do |card|
      if DREAMCAST_SETS.include?(card["set_code"])
        card["dreamcast"] = true
      elsif DREAMCAST_EXTRA_CARDS.fetch(card["set_code"], []).include?(card["name"])
        card["dreamcast"] = true
        matched << card["name"]
      end
    end

    missed_cards = DREAMCAST_EXTRA_CARDS.values.flatten.to_set - matched

    missed_cards.each do |name|
      warn "Dreamcast card: #{name} not matched"
    end
  end
end
