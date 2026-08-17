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
    @tokens = @deck.tokens

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
      upload = params[:deck_upload]
      @deck = upload.respond_to?(:read) ? upload.read : upload.to_s
      preprocessor = UserDeckPreprocessor.new(@deck)
      if preprocessor.valid?
        @deck = preprocessor.text
      else
        @warnings = ["Can't parse uploaded deck."]
        @deck = ""
      end
    else
      @deck = params[:deck]
    end

    if @deck.present?
      parser = DeckParser.new($CardDatabase, @deck)

      @cards = sort_parsed_section(parser.section_cards["Main Deck"])
      @sideboard = sort_parsed_section(parser.section_cards["Sideboard"])
      @commander = sort_parsed_section(parser.section_cards["Commander"])
      @planar_deck = sort_parsed_section(parser.section_cards["Planar Deck"])
      @scheme_deck = sort_parsed_section(parser.section_cards["Scheme Deck"])
      @display_commander = sort_parsed_section(parser.section_cards["Display Commander"])

      @card_previews = [
        *@cards.map(&:last),
        *@sideboard.map(&:last),
        *@commander.map(&:last),
        *@planar_deck.map(&:last),
        *@scheme_deck.map(&:last),
        *@display_commander.map(&:last),
      ].uniq.grep(PhysicalCard)

      choose_default_preview_card
      group_cards
    end
  end

  private

  def sort_section(section)
    section.sort_by{|_,c| [c.name, c.set_code, c.number] }
  end

  # Same, except a pasted deck can contain cards we know nothing about
  def sort_parsed_section(section)
    section.sort_by{|_,c|
      c.is_a?(PhysicalCard) ? [0, c.name, c.set_code, c.number] : [1, c.name]
    }
  end

  def choose_default_preview_card
    # A deck is about its commander, so preview that - looking in the sideboard
    # too, for decks whose commander never got migrated to the new system
    commander = [@commander, @sideboard].find{|section| section.size.between?(1,2)}
    @default_preview_card = commander&.first&.last
    # A pasted decklist can name a card we know nothing about, and there is no
    # picture to preview for that one
    unless @card_previews.include?(@default_preview_card)
      @default_preview_card = PhysicalCard.best_preview(@card_previews)
    end
  end

  def group_cards
    @card_groups = @cards.group_by do |count, card|
      card.nil? ? UnknownCard::TYPE_GROUP : card.type_group
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
