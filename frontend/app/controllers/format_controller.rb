class FormatController < ApplicationController
  def index
    @formats = Format.all_format_classes.map do |format_class|
      format_class.new
    end
    @title = "Formats"
  end

  def show
    @format = Format[params[:id].tr("-", " ")].new
    if @format.format_pretty_name == "Unknown"
      render_404
      return
    end
    @title = @format.format_pretty_name
    @banned = search_best_printings(%[banned:"#{@format.format_pretty_name}"])
    @restricted = search_best_printings(%[restricted:"#{@format.format_pretty_name}"])
    if @format.included_sets
      @included_sets = @format.included_sets.map{|set_code| $CardDatabase.sets[set_code] }.reverse
    end
    @events = @format.ban_events
  end

  private

  def search_best_printings(query)
    results = $CardDatabase.search(query).printings
    results.group_by(&:name).sort.map do |name, printings|
      best_printing = printings.find{|cp| ApplicationHelper.card_picture_path(cp) } || printings[0]
      best_printing
    end
  end
end
