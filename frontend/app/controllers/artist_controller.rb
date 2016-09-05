class ArtistController < ApplicationController
  def index
    @title = "Artists"
    @artists = Hash.new(0)
    $CardDatabase.sets.each_value do |set|
      set.printings.each do |printing|
        @artists[printing.artist] += 1
      end
    end
    @artists = @artists.sort
  end

  def show
    id = params[:id]
    @artist = $CardDatabase.artists[id]
    unless @artist
      render_404
      return
    end

    @title = @artist.name
    @printings = @artist.printings.sort_by{|c| [-c.release_date.to_i_sort, c.set_name, c.name]}
    page = [1, params[:page].to_i].max
    @printings = @printings.paginate(page: page, per_page: 60)
  end
end
