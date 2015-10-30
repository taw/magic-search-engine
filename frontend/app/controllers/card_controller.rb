class CardController < ApplicationController
  def show
    set = params[:set]
    number = params[:id]
    if $CardDatabase.sets[set]
      @card = $CardDatabase.sets[set].printings.find{|cp| cp.number == number}
    end
    unless @card
      render file: "#{Rails.root}/public/404.html", layout: false, status: 404
    end
  end
end
