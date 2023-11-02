class PatchDecks < Patch
  def remove_decks_for_unknown_sets
    valid_set_codes = @sets.map{|s| s["code"] }.to_set
    @decks.select!{|d| valid_set_codes.include?(d["set_code"]) }
  end

  def resolve_printings
    @decks.each do |deck|
      # Map new section system back into the old for now
      sections = deck["cards"]
      deck["cards"] = {}
      deck["sideboard"] = []
      deck["commander"] = []

      sections.each do |section_name, section_cards|
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
  end

  def resolve_printing(deck, card)
    return nil if card["token"]
    DeckPrintingResolver.new(@cards, @sets, deck, card).call
  end

  def call
    remove_decks_for_unknown_sets
    resolve_printings
  end
end
