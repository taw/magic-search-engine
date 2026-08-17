# This is not a real playable format, it's just a query.
# It shows what Standard is going to look like after the next rotation,
# including sets which aren't released yet.
class FormatFuture < FormatStandard
  # Newest first, so the next rotation is the last one that hasn't happened yet
  def build_included_sets
    rotation_sets rotations.take_while{|rotation_time, _| rotation_time > rotation_reference_time}.last
  end

  def format_pretty_name
    "Future Standard"
  end

  # It's all one hypothetical rotation, there's no history to show
  def display_rotation_schedule?
    false
  end

  # Nothing knows what will be banned after the rotation, current Standard ban list is the best guess
  def ban_list_name
    "standard"
  end
end
