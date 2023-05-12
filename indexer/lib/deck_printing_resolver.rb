class DeckPrintingResolver
  # We know basics are ambiguous, we don't even care
  # Basics and guildgates (without special effects), nobody really cares which one you'll get
  # There are exception like JMP and WC* but they are annotated in data
  CardsWithAllowedConflicts = [
    "Plains",
    "Island",
    "Swamp",
    "Mountain",
    "Forest",
    "Wastes",
    "Azorius Guildgate",
    "Boros Guildgate",
    "Dimir Guildgate",
    "Golgari Guildgate",
    "Gruul Guildgate",
    "Izzet Guildgate",
    "Orzhov Guildgate",
    "Rakdos Guildgate",
    "Selesnya Guildgate",
    "Simic Guildgate",
  ]

  SetSearchList = {
    # otherwise it returns GRN and that's bad
    "gnt" => ["m19"],
    "c20" => ["iko"],
    "znc" => ["znr"],
    "jmp" => ["m21"],
    # Coldsnap had special set for Ice Age reprints
    "csp" => ["cst"],
    # S00 on Gatherer includes all 6ED reprints but mtgjson doesn't
    "s00" => ["6ed"],
    # It seems that Masters Edition 2 precons contained Masters Edition cards too
    "me2" => ["me1"],
  }

  def initialize(cards, sets, deck, card)
    @cards = cards
    @sets = sets.to_h{|s| [s["code"], s]}
    @deck = deck
    @card = card
  end

  def release_date(set_code)
    Date.parse(@sets[set_code]["release_date"])
  end

  def deck_set_code
    @deck_set_code ||= @deck["set_code"]
  end

  def deck_name
    @deck["name"]
  end

  def card_name
    @card["name"]
  end

  def set_search_list
    SetSearchList[deck_set_code]
  end

  def deck_release_date
    @deck_release_date ||= if deck_set_code == "w17"
      # Welcome decks contain some future cards
      release_date("akh")
    else
      release_date(deck_set_code)
    end
  end

  def set_is_precon_or_promo?(set_code)
    !(["promo", "commander", "masters", "duel deck", "planechase",
     "premium deck", "un", "conspiracy", "from the vault", "archenemy"] &
     @sets[set_code]["types"]).empty?
  end

  def card_name
    @card_name ||= @card["name"].split(" // ")[0]
  end

  def card_set
    @card_set ||= @card["set"]&.downcase
  end

  def card_number
    @card_number ||= @card["number"]&.downcase
  end

  def card_info
    @card_info ||= @cards[card_name]
  end

  def resolve_set
    raise "Card not found #{deck_set_code} #{card_name}" unless card_info
    printings = card_info.group_by{|c| c["set_code"]}

    if card_set
      printings_in_specified_set = printings[card_set]
      return printings_in_specified_set if printings_in_specified_set
      raise "Set #{card_set} explicitly specified but no such printing for #{card_name}"
    end

    # It was printed in set we want
    return printings[deck_set_code] if printings[deck_set_code]

    # Explicitly provided list
    if set_search_list
      return set_search_list.map{|c| printings[c]}.find(&:itself) || raise("Can't find #{card_name} in any possible set")
    end

    # It was not from our set, but only printed once
    return printings.values[0] if printings.size == 1

    # First, filter out all printings from future sets
    printings = printings.select{|sc, _| release_date(sc) <= deck_release_date }

    # # All other printings in the future, so we don't care
    return printings.values[0] if printings.size == 1
    raise "All printings of #{card_name} from the future" if printings.empty?

    # Promos/Precons are never the right answer
    printings = printings.reject{|sc, _| set_is_precon_or_promo?(sc) }
    return printings.values[0] if printings.size == 1
    raise "All printings of #{card_name} from the promo/precon cards" if printings.empty?

    # If it was printed in earlier sets of same block, ignore everything else
    block_name = @sets[deck_set_code]["block_name"]
    if block_name
      same_block_printings = printings.select{|sc,_|
        block_name && block_name == @sets[sc]["block_name"]
      }
      printings = same_block_printings unless same_block_printings.empty?
    end
    return printings.values[0] if printings.size == 1

    # At this point we can guess most recent standard set printing
    most_recent_standard_set, most_recent_standard_printing = printings.select{|sc,_|
      @sets[sc]["types"].include?("standard")
    }.sort_by{|sc, _|
      release_date(sc)
    }.last

    unless most_recent_standard_printing
      raise "No Standard legal printing found for #{set_code} #{card_name}"
    end

    mrsp_date = release_date(most_recent_standard_set)
    age = (deck_release_date - mrsp_date).to_i
    if age < 2 * 365
      # Would be nicer to check if actually same Standard
      # OK
    elsif @deck["type"] == "Pioneer Challenger Deck"
      # OK
    else
      warn "#{age} is too old #{deck_set_code} #{card_name} #{most_recent_standard_set}"
    end
    return most_recent_standard_printing
  end

  def resolve_card
    printings = resolve_set
    raise if printings.empty? # Shouldn't happen

    if card_number
      specified_card = printings.find{|c| c["number"].downcase == card_number}
      return specified_card if specified_card
      raise "Number #{card_number} requested for #{card["name"]} but no such card found"
    end

    return printings[0] if printings.size == 1

    # Not unique, but we have a few more heuristics to try!
    # If these heuristics are wrong, disambiguation hints can be added upstream

    # Sort them in predictable order, by number
    printings = printings.sort_by{|c| [c["number"].to_i, c["number"]] }

    # If some printings have special frame effects, and others don't,
    # use ones without special frame effects
    min_effects = printings.map{|c| c["frame_effects"] || [] }.inject{|a,b| a&b}
    printings_with_min_effects = printings.select{|c| (c["frame_effects"] || []) == min_effects}
    printings = printings_with_min_effects unless printings_with_min_effects.empty?

    # And same logic for full art cards
    # This is especially true for basics
    printings_without_fullart = printings.select{|c| !c["fullart"] }
    printings = printings_without_fullart unless printings_without_fullart.empty?

    # And same logic for borderless cards
    printings_with_borders = printings.select{|c| c["border"] != "borderless" }
    printings = printings_with_borders unless printings_with_borders.empty?

    return printings[0] if printings.size == 1

    numbers = printings.map{|c| c["number"]}

    return printings[0] if CardsWithAllowedConflicts.include?(card_name) and deck_set_code != "ptc"

    # If there are variant cards († or ★), choose non-variant version
    # If this needs to be reversed, mark it explicitly in the data

    if numbers.map(&:to_i).uniq.size == 1
      base_number = numbers.map(&:to_i).uniq[0].to_s
      base_variant = printings.find{|c| c["number"] == base_number}
      return base_variant if base_variant
    end

    # Otherwise just get one with lowest number, but print a warning
    # Use same format as magic-preconstructed-decks for easy copypasta
    candidates = printings.map{|c| "[#{c["set_code"].upcase}:#{c["number"]}]" }
    candidates.each do |candidate|
      puts "bin/resolve_card #{deck_set_code.inspect} #{deck_name.inspect} #{card_name.inspect} #{candidate.inspect}"
    end
    printings[0]
  end

  def call
    printing_card = resolve_card
    foil_res = (@card["foil"] || printing_card["foiling"] == "foilonly") ? ["foil"] : []
    [@card["count"], printing_card["set_code"], printing_card["number"]] + foil_res
  end

  def inspect
    self.class.to_s
  end
end
