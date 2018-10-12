class FormatCustomEternal < Format
  def format_pretty_name
    "Custom Eternal"
  end

  def include_custom_sets?
    true
  end

  def build_included_sets
    rotation_schedule = Format["custom standard"].new(@time).rotation_schedule
    included_sets = rotation_schedule.flat_map do |rotation_time, rotation_sets|
      rotation_time = Date.parse(rotation_time)
      if !@time or @time >= rotation_time
        rotation_sets
      else
        []
      end
    end
    Set.new(included_sets)
  end
end
