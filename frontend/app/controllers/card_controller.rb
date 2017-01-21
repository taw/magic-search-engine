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

  def gallery
    set = params[:set]
    number = params[:id]
    if $CardDatabase.sets[set]
      @card = $CardDatabase.sets[set].printings.find{|cp| cp.number == number}
    end

    if @card
      first_printing = @card.printings.first
      if @card == first_printing
        @title = @card.name
        page = [1, params[:page].to_i].max
        @total_printings = @card.printings.size
        @printings = paginate_by_set(@card.printings, page)
      else
        redirect_to set: first_printing.set_code, id: first_printing.number
      end
    else
      render_404
    end
  end

  # Logic tested in CLIFrontend, probably should be moved to database
  # as this untested copypasta is nasty
  # FIXME: And now it's not even the same anymore
  def index
    @search = (params[:q] || "").strip
    page = [1, params[:page].to_i].max

    unless @search.present?
      @empty_page = true
      @cards = []
      return
    end

    @title = @search
    query = Query.new(@search)
    results = $CardDatabase.search(query)
    @warnings = results.warnings
    @cards = results.card_groups.map do |printings|
      choose_best_printing(printings)
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

  def choose_best_printing(printings)
    best_printing = printings.find{|cp| ApplicationHelper.card_picture_path(cp) } || printings[0]
    [best_printing, printings]
  end
end
