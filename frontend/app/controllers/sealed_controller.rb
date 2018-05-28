class SealedController < ApplicationController
  def index

    @count = (params[:count] || 6).to_i
    @set_code = params[:set]

    @sets = $CardDatabase.sets_with_packs

    factory = PackFactory.new($CardDatabase)
    pack = factory.for(@set_code) if @set_code

    if pack
      @cards = @count.times.flat_map{ pack.open }
    end

    @title = "Sealed"
  end
end
