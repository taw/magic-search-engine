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

    # Special logic for those
    # Cards from Clash Packs take priority even over their official set
    if deck["type"] == "Clash Pack"
      return printings["cp1"] if set_code == "m15" and printings["cp1"]
      return printings["cp2"] if set_code == "frf" and printings["cp2"]
      return printings["cp3"] if set_code == "ori" and printings["cp3"]
    end

    # Coldsnap had special set for Ice Age reprints
    if deck["set_code"] == "cs"
      return printings["cstd"] if printings["cstd"]
    end

    # It was printed in set we want
    return printings[set_code] if printings[set_code]

    # It was not from our set, but only printed once
    return printings.values[0] if printings.size == 1

    # First, filter out all printings from future sets
    printings = printings.select{|sc, _|
      release_date(sc) <= set_date
    }
    # All other printings in the future, so we don't care
    return printings.values[0] if printings.size == 1
    raise "All printings from the future" if printings.empty?

    # It seems that Masters Edition 2 precons contained Masters Edition cards too
    return printings["med"] if set_code == "me2" and printings["med"]

    # Promos/Precons are never the right answer
    printings = printings.reject{|sc, _|
      ["promo", "commander", "masters", "duel deck", "planechase",
       "premium deck", "un", "conspiracy", "from the vault", "archenemy",
      ].include?(@sets[sc]["type"])
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
      @sets[sc]["type"] == "core" or @sets[sc]["type"] == "expansion"
    }.sort_by{|sc, _|
      release_date(sc)
    }.last

    unless most_recent_standard_printing
      raise "No Standard legal printing found for #{set_code} #{card_name}"
    end

    mrsp_date = release_date(most_recent_standard_set)
    age = (set_date - mrsp_date).to_i
    if age < 2*365
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
    return printings[0] if printings.size == 1
    # Not unique, but we hopefully got the set right, so we mostly don't care
    # At some point we should support disambiguation hints upstream
    return printings[0]
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
      cards: cards,
      sideboard: sideboard,
    }
  end

  def call
    index = @decks.map do |deck|
      index_deck(deck)
    end
    @save_path.write(index.to_json)
  end
end
