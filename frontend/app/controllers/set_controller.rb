class SetController < ApplicationController
  def index
    @sets = $CardDatabase.sets.values.sort_by{|s| [s.release_date, s.set_name]}
  end

  def show
    id = params[:id]
    @set = $CardDatabase.sets[id]
    render_404 unless @set
    @cards = @set.printings.sort_by{|cp| [cp.number.to_i, cp.number]}

    page = [1, params[:page].to_i].max
    @cards = @cards.paginate(page: page, per_page: 25)
  end
end
