class DeckController < ApplicationController
  def show
    @set = $CardDatabase.sets[params[:set]] or return render_404
    @deck = @set.decks.find{|d| d.slug == params[:id]} or return render_404

    @type = @deck.type
    @name = @deck.name
    @set_code = @set.code
    @set_name = @set.name

    @cards = @deck.cards
    @sideboard = @deck.sideboard

    @card_previews = @deck.physical_cards
    @preview_card = @card_previews.first # TODO

    @card_groups = @cards.group_by{|count, card|
      types = card.main_front.types
      if card.nil?
        [0, "Unknown"]
      elsif types.include?("creature")
        [1, "Creature"]
      elsif types.include?("land")
        [7, "Land"]
      elsif types.include?("planeswalker")
        [2, "Planeswalker"]
      elsif types.include?("instant")
        [3, "Instant"]
      elsif types.include?("sorcery")
        [4, "Sorcery"]
      elsif types.include?("artifact")
        [5, "Artifact"]
      elsif types.include?("enchantment")
        [6, "Enchantment"]
      else
        [8, "Other"]
      end
    }
    unless @sideboard.empty?
      @card_groups[[9, "Sideboard"]] = @sideboard
    end
    @card_groups = @card_groups.sort
  end
end
