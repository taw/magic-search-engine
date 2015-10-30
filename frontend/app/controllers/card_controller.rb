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
    @search = params[:q]
    @cards = $CardDatabase.search(@search)
    # paginate etc.
  end
end
