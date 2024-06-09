class DeckController < ApplicationController
  # We don't have any sensitive data, at some point might be good practice to enable it anyway
  skip_before_action :verify_authenticity_token

  def index
    @sets = $CardDatabase.sets.values.reject{|s| s.decks.empty?}.sort_by{|s| [-s.release_date.to_i_sort, s.name] }
    @title = "Preconstructed Decks"
  end

  def download
    @set = $CardDatabase.sets[params[:set]] or return render_404
    @deck = @set.decks.find{|d| d.slug == params[:id]} or return render_404

    headers["Content-Disposition"] = %Q[attachment; filename="#{@deck.name}.txt"]
    render plain: @deck.to_text
  end

  def download_with_printings
    @set = $CardDatabase.sets[params[:set]] or return render_404
    @deck = @set.decks.find{|d| d.slug == params[:id]} or return render_404

    headers["Content-Disposition"] = %Q[attachment; filename="#{@deck.name}.txt"]
    render plain: @deck.to_text_with_printings
  end

  def show
    @set = $CardDatabase.sets[params[:set]] or return render_404
    @deck = @set.decks.find{|d| d.slug == params[:id]} or return render_404

    @type = @deck.type
    @name = @deck.name
    @set_code = @set.code
    @set_name = @set.name
    @release_date = @deck.release_date
    @display = @deck.display
    @format = @deck.format
    @category = @deck.category

    @cards = sort_section(@deck.cards)
    @sideboard = sort_section(@deck.section("Sideboard"))
    @commander = sort_section(@deck.commander)
    @display_commander = sort_section(@deck.section("Display Commander"))
    @planar_deck = sort_section(@deck.section("Planar Deck"))
    @scheme_deck = sort_section(@deck.section("Scheme Deck"))

    @card_previews = @deck.physical_cards

    choose_default_preview_card
    group_cards

    @title = "#{@deck.name} - #{@set.name} #{@deck.type}"
  end

  def visualize
    @title = "Deck Visualizer"

    if params[:deck_upload]
      @deck = params[:deck_upload].read
      parser = UserDeckParser.new(@deck)
      if parser.valid?
        @deck = parser.deck
      else
        @warnings = ["Can't parse uploaded deck."]
        @deck = ""
      end
    else
      @deck = params[:deck]
    end

    if @deck.present?
      parser = DeckParser.new($CardDatabase, @deck)

      @cards = parser.main_cards.sort_by{|_,c|
        c.is_a?(PhysicalCard) ? [0, c.name, c.set_code, c.number] : [1, c.name]
      }
      @sideboard = parser.sideboard_cards.sort_by{|_,c|
        c.is_a?(PhysicalCard) ? [0, c.name, c.set_code, c.number] : [1, c.name]
      }
      @commander = parser.commander_cards.sort_by{|_,c|
        c.is_a?(PhysicalCard) ? [0, c.name, c.set_code, c.number] : [1, c.name]
      }

      @card_previews = [
        *@cards.map(&:last),
        *@sideboard.map(&:last),
        *@commander.map(&:last),
      ].uniq.grep(PhysicalCard)

      choose_default_preview_card
      group_cards
    end
  end

  private

  def sort_section(section)
    section.sort_by{|_,c| [c.name, c.set_code, c.number] }
  end

  def choose_default_preview_card
    # Choose best card to preview
    if @commander.size.between?(1,2)
      # Commander
      @default_preview_card = @commander.first.last
    elsif @sideboard.size.between?(1,2)
      # Commander, if it didn't get migrated to new system
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
    @card_groups = @cards.group_by do |count, card|
      if card.is_a?(UnknownCard) or card.nil?
        [9, "Other"]
      else
        types = card.main_front.types
        if types.include?("creature")
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
      end
    end
    unless @sideboard.blank?
      @card_groups[[10, "Sideboard"]] = @sideboard
    end
    unless @commander.blank?
      @card_groups[[0, "Commander"]] = @commander
    end
    unless @planar_deck.blank?
      @card_groups[[11, "Planar Deck"]] = @planar_deck
    end
    unless @scheme_deck.blank?
      @card_groups[[12, "Scheme Deck"]] = @scheme_deck
    end
    unless @display_commander.blank?
      @card_groups[[13, "Display Commander"]] = @display_commander
    end
    @card_groups = @card_groups.sort
  end
end
