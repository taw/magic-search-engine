class ProductController < ApplicationController
  def index
    @sets = $CardDatabase.sets.values.reject{|s| s.products.empty?}.sort_by{|s| [-s.release_date.to_i_sort, s.name] }
    @title = "Sealed Products"
  end
end
