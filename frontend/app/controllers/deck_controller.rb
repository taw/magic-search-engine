class DeckController < ApplicationController
  def index
    @sets = $CardDatabase.sets.values.reject{|s| s.decks.empty?}.sort_by{|s| [-s.release_date.to_i_sort, s.name] }
    @title = "Preconstructed Decks"
  end

  def download
    @set = $CardDatabase.sets[params[:set]] or return render_404
    @deck = @set.decks.find{|d| d.slug == params[:id]} or return render_404

    headers["Content-Disposition"] = "attachment; filename=#{@deck.name}.txt"
    render plain: @deck.to_text
  end

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

    choose_default_preview_card
    group_cards

    @title = "#{@deck.name} - #{@set.name} #{@deck.type}"
  end

  private

  def choose_default_preview_card
    # Choose best card to preview
    if @sideboard.size == 1
      # Commander
      @default_preview_card = @sideboard.first.last
    else
      @default_preview_card = @card_previews.min_by do |c|
        rarity = c.rarity
        types = c.main_front.types
        score = 0
        score += 10000 if rarity == "mythic"
        score += 1000 if rarity == "rare"
        score += 100 if types.include?("planeswalker")
        score += 10 if types.include?("legendary")
        score += 1 if types.include?("creature")
        [-score, c.name]
      end
    end
  end

  def group_cards
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
