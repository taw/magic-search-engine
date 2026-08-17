class ArtistController < ApplicationController
  def index
    @title = "Artists"
    @artists = $CardDatabase.artists.each_value.sort.map{|artist| [artist, artist.printings.size]}
  end

  def show
    id = params[:id]
    @artist = $CardDatabase.artists[id]
    unless @artist
      render_404
      return
    end

    @total = @artist.printings.size
    @title = @artist.name
    page = [1, params[:page].to_i].max
    @printings = paginate_by_set(@artist.printings, page)
  end
end
