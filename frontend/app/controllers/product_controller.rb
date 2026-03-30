class ProductController < ApplicationController
  def index
    @sets = $CardDatabase.sets.values.reject{|s| s.products.empty?}.sort_by{|s| [-s.release_date.to_i_sort, s.name] }
    @title = "Sealed Products"
  end

  def show
    @set = $CardDatabase.sets[params[:set]] or return render_404
    @product = @set.products.find{|p| p.slug == params[:id]} or return render_404

    @title = "#{@product.name} - #{@set.name}"
  end
end
