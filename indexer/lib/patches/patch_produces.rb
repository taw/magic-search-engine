# This was easier back when there was "mana pool"
# now we need to use a bit fuzzier search
#
# Many of these patterns are seen on just one card each, so this will need occasional updating
#
# There are some borderline cases here.
class PatchProduces < Patch
  TYPES = {
    "Plains" => "w",
    "Island" => "u",
    "Swamp" => "b",
    "Mountain" => "r",
    "Forest" => "g",
  }
  LEGAL_SYMBOLS = %w[w u b r g c]
  # This is better than making the parser crazy complicated
  # especially various uncards wouldh be causing problems
  OVERRIDES = {
    # Normal ards with weird templating
    "Old-Growth Troll" => "g",
    "Rhystic Cave" => "bgruw",
    "Tundra Fumarole" => "c",
    # Uncards and playtest cards
    "Mons's Goblin Waiters" => "r", # {HR}
    "Sole Performer" => nil, # {T}
    "Unglued Pea-Brained Dinosaur" => "c", # {2} that should have been Oracled into {C}{C}
  }

  def call
    each_printing do |card|
      text = card["text"] or next
      name = card["name"]

      if OVERRIDES.key?(name)
        card["produces"] = OVERRIDES[name]
        next
      end

      mana_from_types = card["types"].map{|t| TYPES[t] }.compact

      # annoyingly ' is sometimes terminator and sometimes apostrophy 's or s'
      add_mana_lines = text.scan(/adds? [^\n\."]+/i)

      produces = mana_from_types.to_set

      add_mana_lines.each do |line|
        next unless line =~ /\{|mana(?! value)/i
        # False Dawn, skip (same as we don't count Blood Moon)
        next if line == "add colored mana instead add that much white mana"
        # Mana Abundance
        next if line == "add mana, instead all players add that mana"

        symbols = line.downcase.scan(/\{(.*?)\}/).flatten.uniq.to_set

        # 106.1a There are five colors of mana: white, blue, black, red, and green.
        if line =~ /mana of any color|mana of any one color|mana in any combination of colors|mana of that color|mana of the chosen color|mana in any combination of its colors|mana of different colors|mana of either of the circled colors|one mana of a color written on Your Mana Rock|mana of any of the exiled card's colors|mana of any of this creature's colors|mana of a chosen color|mana of any of the exiled cards' colors|mana of this card's color|mana of each of the chosen colors|mana in any combination of your guild's colors|mana of your guild's colors|mana of the color last chosen|mana of that color/
          symbols += ["w", "u", "b", "r", "g"]
        end

        # 106.1b There are six types of mana: white, blue, black, red, green, and colorless.
        if line =~ /mana of any type|mana of that type|mana lost this way|mana equal to enchanted permanent's mana cost|type and amount of mana|mana of this artifact's last noted type/
          symbols += ["w", "u", "b", "r", "g", "c"]
        end

        if line =~ /Add Colorless mana/
          # The Waffle Restaurant (mtgjson error)
          symbols += ["c"]
        end

        produces += symbols

        if symbols.empty?
          warn "It looks like this produces mana, but indexer doesn't understand what type: #{line}"
        end
      end

      # Urza's Fun House
      if produces.include?("∞")
        produces -= ["∞"]
        produces += ["c"]
      end

      if produces.any?{|s| !LEGAL_SYMBOLS.include?(s)}
        warn "Parse error for #{card["name"]}: #{text}"
      end

      card["produces"] = produces.sort.join unless produces.empty?
    end
  end
end
