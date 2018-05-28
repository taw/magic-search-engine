class SealedController < ApplicationController
  def index
    factory = PackFactory.new($CardDatabase)

    @count = (params[:count] || 6).to_i
    @set_code = params[:set]

    pack = factory.for(@set_code) if @set_code

    @sets = $CardDatabase.sets.values.reverse.select{|set| factory.for(set.code)}
    if @set_code
      @cards = @count.times.flat_map{ pack.open }
    end

    @title = "Sealed"
  end
end
