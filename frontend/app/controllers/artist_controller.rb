class ArtistController < ApplicationController
  def index
    @title = "Artists"
    @artists = Set[]
    $CardDatabase.sets.each_value do |set|
      set.printings.each do |printing|
        @artists << printing.artist
      end
    end
    @artists = @artists.sort
  end

  def show
    id = params[:id]
    @artist = id
    @cards = []
    $CardDatabase.sets.each_value do |set|
      set.printings.each do |printing|
        @cards << printing if printing.artist == id
      end
    end
    @cards.sort_by{|cp| [cp.release_date, cp.number.to_i, cp.number]}
    page = [1, params[:page].to_i].max
    @cards = @cards.paginate(page: page, per_page: 25)
  end
end
