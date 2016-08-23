class CardController < ApplicationController
  def show
    set = params[:set]
    number = params[:id]
    if $CardDatabase.sets[set]
      @card = $CardDatabase.sets[set].printings.find{|cp| cp.number == number}
    end
    if @card
      @title = @card.name
    else
      render_404
    end
  end

  # Logic tested in CLIFrontend, probably should be moved to database
  # as this untested copypasta is nasty
  def index
    @search = (params[:q] || "").strip
    page = [1, params[:page].to_i].max

    if @search.present?
      query = Query.new(@search)
      @title = @search
      results = $CardDatabase.search(query)
      @warnings = results.warnings
      @cards = choose_best_printing(results.printings)
    else
      @cards = []
    end
    @cards = @cards.paginate(page: page, per_page: 25)
  end

  def advanced
    if params[:advanced]
      query = InteractiveQueryBuilder.new(params[:advanced]).query
      if query
        redirect_to action: 'index', q: query
        return
      end
    end

    render "advanced", layout: "no_search_box"
  end

  private

  def choose_best_printing(results)
    results.group_by(&:name).map do |name, printings|
      best_printing = printings.find{|cp| ApplicationHelper.card_picture_path(cp) } || printings[0]
      [best_printing, printings]
    end
  end
end
