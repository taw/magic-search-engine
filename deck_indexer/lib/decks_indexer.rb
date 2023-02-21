require "date"
require "json"
require "pathname"
require "pry"

class DecksIndexer
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

  def initialize(card_index_json, decks_json, save_path)
    main_index = JSON.parse(Pathname(card_index_json).read)
    @sets = main_index["sets"]
    @cards = main_index["cards"]
    @decks = JSON.parse(Pathname(decks_json).read)
    @save_path = Pathname(save_path)
  end

  def release_date(set_code)
    Date.parse(@sets[set_code]["release_date"])
  end

  def resolve_set(card, deck)
    deck_set_code = deck["set_code"]
    card_name = card["name"].split(" // ")[0]
    deck_release_date = release_date(deck_set_code)

    # Welcome decks contain some future cards
    deck_release_date = release_date("akh") if deck_set_code == "w17"

    card_info = @cards[card_name]
    if card_info.nil?
      raise "Card not found #{deck_set_code} #{card_name}"
    end
    printings = card_info["printings"].group_by(&:first)

    if card["set"]
      printings_in_specified_set = printings[card["set"].downcase]
      return printings_in_specified_set if printings_in_specified_set
      raise "Set #{card["set"]} explicitly specified but no such printing for #{card_name}"
    end

    # It was printed in set we want
    return printings[deck_set_code] if printings[deck_set_code]

    if SetSearchList[deck_set_code]
      return SetSearchList[deck_set_code].map{|c| printings[c]}.find(&:itself) || raise("Can't find #{card["name"]} in any possible set")
    end

    # It was not from our set, but only printed once
    return printings.values[0] if printings.size == 1

    # First, filter out all printings from future sets
    printings = printings.select{|sc, _| release_date(sc) <= deck_release_date }

    # All other printings in the future, so we don't care
    return printings.values[0] if printings.size == 1
    raise "All printings of #{card_name} from the future" if printings.empty?

    # Promos/Precons are never the right answer
    printings = printings.reject{|sc, _|
      ["promo", "commander", "masters", "duel deck", "planechase",
       "premium deck", "un", "conspiracy", "from the vault", "archenemy",
      ].any?{|st| @sets[sc]["types"].include?(st) }
    }
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
    elsif deck["type"] == "Pioneer Challenger Deck"
      # OK
    else
      warn "#{age} is too old #{deck_set_code} #{card_name} #{most_recent_standard_set}"
    end
    return most_recent_standard_printing
  end

  def resolve_card(card, deck)
    printings = resolve_set(card, deck)
    raise if printings.empty?

    if card["number"]
      specified_card = printings.find{|s,c| c["number"].downcase == card["number"].downcase}
      return specified_card if specified_card
      raise "Number #{card["number"]} requested for #{card["name"]} but no such card found"
    end

    return printings[0] if printings.size == 1

    # Not unique, but we have a few more heuristics to try!
    # If these heuristics are wrong, disambiguation hints can be added upstream

    # Sort them in predictable order, by number
    printings = printings.sort_by{|sc,c| [sc,c["number"].to_i, c["number"]] }

    # If some printings have special frame effects, and others don't,
    # use ones without special frame effects
    min_effects = printings.map{|_,c| c["frame_effects"] || [] }.inject{|a,b| a&b}
    printings_with_min_effects = printings.select{|_,c| (c["frame_effects"] || []) == min_effects}
    printings = printings_with_min_effects unless printings_with_min_effects.empty?

    # And same logic for full art cards
    # This is especially true for basics
    printings_without_fullart = printings.select{|_,c| !c["fullart"] }
    printings = printings_without_fullart unless printings_without_fullart.empty?

    # And same logic for borderless cards
    printings_with_borders = printings.select{|_,c| c["border"] != "borderless" }
    printings = printings_with_borders unless printings_with_borders.empty?

    return printings[0] if printings.size == 1

    numbers = printings.map{|_, c| c["number"]}

    return printings[0] if CardsWithAllowedConflicts.include?(card["name"])

    # If there are variant cards († or ★), choose non-variant version
    # If this needs to be reversed, mark it explicitly in the data
    if numbers.map(&:to_i).uniq.size == 1
      base_number = numbers.map(&:to_i).uniq[0].to_s
      base_variant = printings.find{|_, c| c["number"] == base_number}
      return base_variant if base_variant
    end

    # Otherwise just get one with lowest number, but print a warning
    # Use same format as magic-preconstructed-decks for easy copypasta
    candidates = printings.map{|c| "[#{c[0].upcase}:#{c[1]["number"]}]" }.join(" ")
    warn "#{deck["set_code"]} #{deck["name"]}: Cannot resolve #{card["name"]}. Candidates are: #{candidates}"
    printings[0]
  end

  def index_card(card, deck)
    set_code, printing_card = resolve_card(card, deck)
    foil_res = (card["foil"] || printing_card["foiling"] == "foilonly") ? ["foil"] : []
    [card["count"], set_code, printing_card["number"]] + foil_res
  end

  def index_deck(deck)
    {
      name: deck["name"],
      type: deck["type"],
      set_name: deck["set_name"],
      set_code: deck["set_code"],
      release_date: deck["release_date"],
      source: deck["source"],
      display: deck["display"],
      cards: deck["cards"].map{|card| index_card(card, deck)},
      sideboard: deck["sideboard"].map{|card| index_card(card, deck)},
      commander: deck["commander"].map{|card| index_card(card, deck)},
    }.compact
  end

  def call
    index = @decks.map do |deck|
      if @sets[deck["set_code"]]
        index_deck(deck)
      else
        warn "Unknown set #{deck["set_code"]}"
        nil
      end
    end.compact
    @save_path.write(index.to_json)
  end

  def inspect
    self.class.to_s
  end
end
