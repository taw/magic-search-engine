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
    page = [1, params[:page].to_i].max
    @printings = paginate_by_set(@artist.printings, page)
  end
end
