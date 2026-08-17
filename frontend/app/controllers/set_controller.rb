class SetController < ApplicationController
  def index
    @sets = $CardDatabase.sets.values.sort_by{|s| [-s.release_date.to_i_sort, s.name] }
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
    @cards = @set.printings.sort_by(&:number_sort_index)

    @boosters = $CardDatabase.unique_supported_booster_types.select{|code, booster| @set == booster.set}

    page = [1, params[:page].to_i].max
    @cards = @cards.paginate(page: page, per_page: 25)
    @first_page = (page == 1)
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
      .sort_by{|cp| [cp.name, cp.number_sort_index]}
  end

  def missing_scans
    id = params[:id]
    @set = $CardDatabase.sets[id]
    unless @set
      render_404
      return
    end

    @title = @set.name
    @cards = @set
      .printings
      .sort_by{|cp| [cp.name, cp.number_sort_index]}
      .reject(&:image_path)

    render :verify_scans
  end
end
