class CardController < ApplicationController
  def show
    @card = $CardDatabase.printing(params[:set], params[:id])
    if @card
      @title = @card.name
      @legality = @card.legality_information
    else
      render_404
    end
  end

  def gallery
    @card = $CardDatabase.printing(params[:set], params[:id])
    if @card
      default_printing = @card.default_printing
      if @card == default_printing
        @title = @card.name
        page = [1, params[:page].to_i].max
        @total_printings = @card.printings.size
        @printings = paginate_by_set(@card.printings, page)
      else
        redirect_to set: default_printing.set_code, id: default_printing.number
      end
    else
      render_404
    end
  end

  def availability
    @card = $CardDatabase.printing(params[:set], params[:id])
    if @card
      default_printing = @card.default_printing
      if @card == default_printing
        @title = @card.name
        @total_printings = @card.printings.size
        @availability = $CardDatabase.availability_of_all_printings(@card)
        @printings = group_by_set(@card.printings)
      else
        redirect_to set: default_printing.set_code, id: default_printing.number
      end
    else
      render_404
    end
  end

  # Logic tested in CLIFrontend, probably should be moved to database
  # as this untested copypasta is nasty
  # FIXME: And now it's not even the same anymore
  def index
    if request.path == "/card" && params[:page].present?
      # just permit everything
      redirect_to params.to_enum.to_h
      return
    end

    @search = (params[:q] || "").strip
    page = [1, params[:page].to_i].max

    unless @search.present?
      @empty_page = true
      @cards = []
      return
    end

    @title = @search
    query = Query.new(@search, params[:random_seed])
    @seed = query.seed

    metric :page, page
    results = measure :search do
      # There are probably valid queries that can trigger this, especially on a small busy server
      Timeout.timeout(5) do
        $CardDatabase.search(query)
      end
    end
    @warnings = results.warnings

    # card_groups regroups on every call, so keep the one we've got
    card_groups = results.card_groups
    metric :results, card_groups.size

    view_mode = query.view || cookies["default_view"] || "default"

    case view_mode
    when "full"
      # force detailed view
      @cards = paginate_card_groups(card_groups, page, 10)
      render "index_full"
    when "images"
      @cards = paginate_card_groups(card_groups, page, 60)
      render "index_images"
    when "text"
      @cards = paginate_card_groups(card_groups, page, 60)
      render "index_text"
    when "checklist"
      @cards = paginate_card_groups(card_groups, page, 500)
      render "index_checklist"
    else
      # default view
      @cards = paginate_card_groups(card_groups, page, 25)
    end
  end

  private

  # Only the groups on this page ever get rendered, so pick the best printing
  # after slicing rather than before. "sort:newall" groups ~36k cards, and
  # mapping all of them to throw away all but 25 was most of the time this
  # action spent outside the search itself.
  def paginate_card_groups(card_groups, page, per_page)
    WillPaginate::Collection.create(page, per_page, card_groups.size) do |pager|
      window = card_groups[pager.offset, pager.per_page] || []
      pager.replace(window.map{|printings| [SearchResults.best_printing(printings), printings]})
    end
  end
end
