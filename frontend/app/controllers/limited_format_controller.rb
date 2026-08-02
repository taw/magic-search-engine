class LimitedFormatController < ApplicationController
  def index
    @sets = $CardDatabase.sets.values.reject{|s| s.limited_formats.empty?}.sort_by{|s| [-s.release_date.to_i_sort, s.name] }
    @title = "Limited Formats"
  end
end
