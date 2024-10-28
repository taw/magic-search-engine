class PatchDecks < Patch
  def remove_decks_for_unknown_sets
    valid_set_codes = @sets.map{|s| s["code"] }.to_set
    @decks.select!{|d| valid_set_codes.include?(d["set_code"]) }
  end

  def resolve_printings
    @decks.delete_if do |deck|
      begin
        resolve_printings_for_deck(deck)
        false
      rescue
        warn "Skipping deck #{deck['set_name']} - #{deck['name']} due to error: #{$!}"
        true
      end
    end
  end

  def resolve_printings_for_deck(deck)
    sections = deck["cards"]
    deck["cards"] = {}
    deck["tokens"] = []

    sections.each do |section_name, section_cards|
      deck["tokens"].push *section_cards.select{|card| card["token"]}.map{|token| format_token(token)}
      section_cards = section_cards.reject{|card| card["token"]}
      section_cards = section_cards.map{|card| resolve_printing(deck, card) }.compact

      case section_name
      when "Main Deck", "Commander", "Sideboard", "Planar Deck", "Display Commander", "Scheme Deck"
        deck["cards"][section_name] ||= []
        deck["cards"][section_name] += section_cards
      else
        # If identical card appears in multiple section, this merging isn't great, but I don't think this ever happens
        warn "Unknown section name #{section_name}"
        deck["cards"]["Sideboard"] ||= []
        deck["cards"]["Sideboard"] += section_cards
      end
    end

    unless deck["release_date"]
      warn "No release date for #{deck["set_code"]} #{deck["name"]}, defaulting to set release date"
      deck["release_date"] = @sets.find{|s| s["code"] == deck["set_code"]}["release_date"]
    end
  end

  def resolve_printing(deck, card)
    DeckPrintingResolver.new(@cards, @sets, deck, card).call
  end

  def format_token(token)
    [token["count"], token["name"], token["set"], token["number"], !!token["foil"]]
  end

  def call
    remove_decks_for_unknown_sets
    resolve_printings
  end
end
