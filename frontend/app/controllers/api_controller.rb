class ApiController < ApplicationController
  def show
    set = params[:set]
    number = params[:id]
    if $CardDatabase.sets[set]
      @card = $CardDatabase.sets[set].printings.find{|cp| cp.number == number}
    end
    if @card
      render json: card_as_json(@card)
    else
      render json: { "error": "Not found" }, status: 404
    end
  end

  def search
    @search = (params[:q] || "").strip
    page = [1, params[:page].to_i].max

    if @search.present?
      query = Query.new(@search)
      results = $CardDatabase.search(query)
      @warnings = results.warnings
      @cards = results.card_groups.map do |printings|
        choose_best_printing(printings)
      end
    else
      @warnings = nil
      @cards = []
    end
    @cards = @cards.paginate(page: page, per_page: 10)

    render json: {
      total: @cards.total_entries,
      warnings: @warnings,
      cards: @cards.map{|card| card_as_json(card)}
    }
  end

  private

  def choose_best_printing(printings)
    best_printing = printings.find{|cp| ApplicationHelper.card_picture_path(cp) } || printings[0]
    best_printing
  end

  def card_as_json(card)
    {
      name: card.name,
      text: card.text,
      mana_cost: card.mana_cost,
      typeline: card.typeline,
      power: card.power,
      toughness: card.toughness,
      loyalty: card.loyalty,
      image_path: helpers.card_picture_path(card),
      card_path: helpers.url_for_card(card),
    }
  end
end
