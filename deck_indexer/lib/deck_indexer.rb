require "json"
require "pathname"
require "date"

class DeckIndexer
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
    set_code = deck["set_code"]
    card_name = card["name"]
    set_date = release_date(set_code)

    # Welcome decks contain some future cards
    set_date = release_date("akh") if set_code == "w17"

    # * means from previous set on some old Wizards listings
    # We should probably just get rid of it upstream
    card_name = card_name.sub(/\*\z/, "")
    card_name = card_name.split(" // ")[0]

    card_info = @cards[card_name]
    if card_info.nil?
      raise "Card not found #{set_code} #{card_name}"
    end
    printings = card_info["printings"].group_by(&:first)

    if card["set"]
      printings_in_specified_set = printings[card["set"].downcase]
      return printings_in_specified_set if printings_in_specified_set
      raise "Set #{card["set"]} explicitly specified but no such printing for #{card_name}"
    end

    # Special logic for those
    # Cards from Clash Packs take priority even over their official set
    if deck["type"] == "Clash Pack"
      return printings["cp1"] if set_code == "m15" and printings["cp1"]
      return printings["cp2"] if set_code == "frf" and printings["cp2"]
      return printings["cp3"] if set_code == "ori" and printings["cp3"]
    end

    # otherwise it returns GRN and that's bad
    if set_code == "gnt"
      return printings["gnt"] || printings["m19"] || raise
    end

    if set_code == "c20"
      return printings["c20"] || printings["iko"] || raise
    end

    # Coldsnap had special set for Ice Age reprints
    if deck["set_code"] == "csp"
      return printings["cst"] if printings["cst"]
    end

    # S00 on Gatherer includes all 6ED reprints but mtgjson doesn't
    if deck["set_code"] == "s00"
      return printings["s00"] if printings["s00"]
      return printings["6ed"] if printings["6ed"]
    end

    # It was printed in set we want
    return printings[set_code] if printings[set_code]

    # It was not from our set, but only printed once
    return printings.values[0] if printings.size == 1

    # First, filter out all printings from future sets
    printings = printings.select{|sc, _| release_date(sc) <= set_date }

    # All other printings in the future, so we don't care
    return printings.values[0] if printings.size == 1
    raise "All printings from the future" if printings.empty?

    # It seems that Masters Edition 2 precons contained Masters Edition cards too
    return printings["me1"] if set_code == "me2" and printings["me1"]

    # Promos/Precons are never the right answer
    printings = printings.reject{|sc, _|
      ["promo", "commander", "masters", "duel deck", "planechase",
       "premium deck", "un", "conspiracy", "from the vault", "archenemy",
      ].any?{|st| @sets[sc]["types"].include?(st) }
    }
    return printings.values[0] if printings.size == 1
    raise "All printings from the promo/precon cards" if printings.empty?

    # If it was printed in earlier sets of same block, ignore everything else
    block_name = @sets[set_code]["block_name"]
    if block_name
      same_block_printings = printings.select{|sc,_|
        block_name && block_name == @sets[sc]["block_name"]
      }
      printings = same_block_printings unless same_block_printings.empty?
    end
    return printings.values[0] if printings.size == 1

    # At this point we can guess most recent standard set printing
    most_recent_standard_set, most_recent_standard_printing = printings.select{|sc,_|
      @sets[sc]["types"].include?("core") or @sets[sc]["types"].include?("expansion")
    }.sort_by{|sc, _|
      release_date(sc)
    }.last

    unless most_recent_standard_printing
      raise "No Standard legal printing found for #{set_code} #{card_name}"
    end

    mrsp_date = release_date(most_recent_standard_set)
    age = (set_date - mrsp_date).to_i
    if age < 2 * 365
      # Would be nicer to check if actually same Standard
      # OK
    else
      warn "#{age} is too old #{set_code} #{card_name} #{most_recent_standard_set}"
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

    # We know basics are ambiguous, we don't even care
    allowed_conflicts = [
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

    numbers = printings.map{|_, c| c["number"]}

    # Basics and guildgates (without special effects), nobody really cares
    # which one you'll get
    if allowed_conflicts.include?(card["name"])
      return printings[0]
    end

    # If there are variant cards († or ★), choose non-variant version
    # If this needs to be reversed, mark it explicitly in the data
    if numbers.map(&:to_i).uniq.size == 1
      base_number = numbers.map(&:to_i).uniq[0].to_s
      base_variant = printings.find{|_, c| c["number"] == base_number}
      return base_variant if base_variant
    end

    # Otherwise just get one with lowest number, but print a warning
    warn "#{deck["set_code"]} #{deck["name"]}: Cannot resolve #{card["name"]}. Candidates are: #{printings.map{|c| [c[0], "/", c[1]["number"]].join }.join(", ")}"
    printings[0]
  end

  def index_card(card, deck)
    printing = resolve_card(card, deck)
    [card["count"], printing[0], printing[1]["number"]] + (card["foil"] ? ["foil"] : [])
  end

  def index_deck(deck)
    cards = deck["cards"].map do |card|
      index_card(card, deck)
    end
    sideboard = deck["sideboard"].map do |card|
      index_card(card, deck)
    end
    {
      name: deck["name"],
      type: deck["type"],
      set_name: deck["set_name"],
      set_code: deck["set_code"],
      release_date: deck["release_date"],
      cards: cards,
      sideboard: sideboard,
    }.compact
  end

  def call
    index = @decks.map do |deck|
      index_deck(deck)
    end
    @save_path.write(index.to_json)
  end
end
