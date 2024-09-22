class PatchDisplayPowerToughness < Patch
  def call
    each_printing do |card|
      next unless card["power"]
      power = card["power"]
      toughness = card["toughness"]
      augment = (card["text"] || "").include?("Augment {")
      card["power"] = format_powtou(power)
      card["toughness"] = format_powtou(toughness)
      card["display_power"] = format_display_powtou(power, augment)
      card["display_toughness"] = format_display_powtou(toughness, augment)
    end
  end

  def format_display_powtou(value, augment)
    # Only two kinds of Uncards have special handling here:
    # * Unstable augment cards (which are all +2/+0 etc.)
    # * Unhinged half-pow/tou cards
    if value =~ /\A(\d*)½\z/ or augment
      value
    elsif value =~ /\A(\d*)\.5\z/
      "#{$1}½"
    else
      nil
    end
  end

  def format_powtou(value)
    case value
    when nil
      value
    when /\A[\-\+]?\d+\z/
      value.to_i
    when /\A(\d*)\.5\z/
      $1.to_i + 0.5
    when /\A(\d*)½\z/
      $1.to_i + 0.5
    when "*{^2}"
      "*²"
    when /\*/, "∞", "?"
      value
    when "{Defense:4}"
      "4"
    else
      raise "Not sure what to do with #{value.inspect}"
    end
  end
end
