class LimitedFormatController < ApplicationController
  def index
    @sets = $CardDatabase.sets.values.reject{|s| s.limited_formats.empty?}.sort_by{|s| [-s.release_date.to_i_sort, s.name] }
    @title = "Limited Formats"
  end

  # Only draft has a page so far
  SUPPORTED_TYPES = ["draft"]

  def show
    @set = $CardDatabase.sets[params[:set]] or return render_404
    @limited_format = @set.limited_formats.find{|f| f.slug == params[:id]} or return render_404
    return render_404 unless SUPPORTED_TYPES.include?(@limited_format.type)

    @title = @limited_format.to_s
    render @limited_format.type
  end
end
