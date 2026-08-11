class CardController < ApplicationController
  def show
    set = params[:set]
    number = params[:id]
    if $CardDatabase.sets[set]
      @card = $CardDatabase.sets[set].printings.find{|cp| cp.number == number}
    end
    if @card
      @title = @card.name
      @legality = @card.legality_information
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

    # Temporary issue with bots
    # (user agents are on every request's METRICS line now, see RequestMetrics)
    if request.headers['HTTP_USER_AGENT'] =~ /MJ12bot|PetalBot|Bytespider/ and params[:page]
      render_403
      return
    end
    # End of temporary bot code

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
      pager.replace(window.map{|printings| choose_best_printing(printings)})
    end
  end

  def choose_best_printing(printings)
    best_printing = printings.find(&:image_path) || printings[0]
    [best_printing, printings]
  end
end
