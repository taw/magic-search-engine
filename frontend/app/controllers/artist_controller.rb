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
    @artist = id
    @cards_by_set = {}
    sets = $CardDatabase.sets.values.sort_by{|s| [-s.release_date.to_i_sort, s.code]}
    sets.each do |set|
      cards = set.printings.select{|printing| printing.artist == id}
      if cards.present?
        @cards_by_set[set] ||= cards
      end
    end
    @cards_total = @cards_by_set.values.map(&:size).inject(0, &:+)
    # @cards.sort_by{|cp| [cp.release_date, cp.number.to_i, cp.number]}
    # page = [1, params[:page].to_i].max
    # @cards = @cards.paginate(page: page, per_page: 25)
  end
end
