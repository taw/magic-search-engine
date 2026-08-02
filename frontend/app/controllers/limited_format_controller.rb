class LimitedFormatController < ApplicationController
  def index
    @sets = $CardDatabase.sets.values.reject{|s| s.limited_formats.empty?}.sort_by{|s| [-s.release_date.to_i_sort, s.name] }
    @title = "Limited Formats"
  end

  SUPPORTED_TYPES = ["draft", "sealed", "prerelease-sealed"]

  def show
    @set = $CardDatabase.sets[params[:set]] or return render_404
    @limited_format = @set.limited_formats.find{|f| f.slug == params[:id]} or return render_404
    return render_404 unless SUPPORTED_TYPES.include?(@limited_format.type)

    @title = @limited_format.to_s
    render template_for(@limited_format)
  end

  # Sealed formats with random packs or an unusual way of playing them are not
  # described yet, and only get a placeholder
  private def template_for(limited_format)
    if limited_format.format_type == "draft"
      "draft"
    elsif limited_format.describable_sealed?
      "sealed"
    else
      "placeholder"
    end
  end
end
