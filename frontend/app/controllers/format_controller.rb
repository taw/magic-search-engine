class FormatController < ApplicationController
  def index
    @formats = Format.all_format_classes.map do |format_class|
      format_class.new
    end
    @title = "Formats"
  end
end
