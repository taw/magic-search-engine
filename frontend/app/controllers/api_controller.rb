class ApiController < ApplicationController
  def show
    set = params[:set]
    number = params[:id]
    if $CardDatabase.sets[set]
      @card = $CardDatabase.sets[set].printings.find{|cp| cp.number == number}
    end
    if @card
      render json: {
        name: @card.name,
        text: @card.text,
        mana_cost: @card.mana_cost,
        typeline: @card.typeline,
        power: @card.power,
        toughness: @card.toughness,
        loyalty: @card.loyalty,
        image_path: helpers.card_picture_path(@card),
        card_path: helpers.url_for_card(@card),
      }
    else
      render json: { "error": "Not found" }, status: 404
    end
  end
end
