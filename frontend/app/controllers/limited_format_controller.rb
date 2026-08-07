class LimitedFormatController < ApplicationController
  def index
    @sets = $CardDatabase.sets.values.reject{|s| s.limited_formats.empty?}.sort_by{|s| [-s.release_date.to_i_sort, s.name] }
    @title = "Limited Formats"
  end

  # Formats with a page of their own. Sets whose Arena boosters changed from
  # run to run have one numbered format per run, so those are a pattern.
  SUPPORTED_TYPES = ["draft", "mtgo-draft", "sealed", "prerelease-sealed", "jumpstart", /\Aarena-draft(-\d+)?\z/]

  def self.supported_type?(type)
    SUPPORTED_TYPES.any?{|supported| supported === type}
  end

  def show
    @set = $CardDatabase.sets[params[:set]] or return render_404
    @limited_format = @set.limited_formats.find{|f| f.slug == params[:id]} or return render_404
    return render_404 unless self.class.supported_type?(@limited_format.type)

    @title = @limited_format.to_s
    render template_for(@limited_format)
  end

  # Formats with random packs, or ones played in a way we have no rules text
  # for, are not described yet, and only get a placeholder
  private def template_for(limited_format)
    if limited_format.describable_draft?
      "draft"
    elsif limited_format.describable_sealed?
      "sealed"
    else
      "placeholder"
    end
  end
end
