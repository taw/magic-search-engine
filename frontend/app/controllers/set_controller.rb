class SetController < ApplicationController
  def index
    @sets = $CardDatabase.sets.values.sort_by{|s| [s.release_date, s.name]}
    @title = "Sets"
  end

  def show
    id = params[:id]
    @set = $CardDatabase.sets[id]
    unless @set
      render_404
      return
    end

    @title = @set.name
    @cards = @set.printings.sort_by{|cp| [cp.number.to_i, cp.number]}

    page = [1, params[:page].to_i].max
    @cards = @cards.paginate(page: page, per_page: 25)
  end

  def verify_scans
    id = params[:id]
    @set = $CardDatabase.sets[id]
    unless @set
      render_404
      return
    end

    @title = @set.name
    @cards = @set
      .printings
      .sort_by{|cp| [cp.name, cp.number.to_i, cp.number]}
  end
end
