class CardController < ApplicationController
  def show
    set = params[:set]
    number = params[:id]
    if $CardDatabase.sets[set]
      @card = $CardDatabase.sets[set].printings.find{|cp| cp.number == number}
    end
    render_404 unless @card
  end

  def index
    @search = params[:q] || ""
    if @search.present?
      @cards = $CardDatabase.search(@search).uniq(&:name)
    else
      @cards = []
    end

    @cards = @cards.paginate(page: params[:page], per_page: 25)
  end
end
