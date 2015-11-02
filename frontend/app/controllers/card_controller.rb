class CardController < ApplicationController
  def show
    set = params[:set]
    number = params[:id]
    if $CardDatabase.sets[set]
      @card = $CardDatabase.sets[set].printings.find{|cp| cp.number == number}
    end
    render_404 unless @card
  end

  # Logic tested in CLIFrontend, probably should be moved to database
  # as this untested copypasta is nasty
  def index
    @search = params[:q] || ""
    page = [1, params[:page].to_i].max

    query = Query.new(@search)
    if @search.present?
      results = $CardDatabase.search(query)
    else
      results = []
    end

    @cards = choose_best_printing(results).paginate(page: page, per_page: 25)
  end

  private

  def choose_best_printing(results)
    results.group_by(&:name).map{|name, printings|
      [printings[0], printings]
    }
  end
end
