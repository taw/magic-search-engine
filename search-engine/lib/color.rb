module Color
  Names = {
    "white" => "w",
    "blue" => "u",
    "black" => "b",
    "red" => "r",
    "green" => "g",

    "azorius" => "wu",
    "dimir" => "ub",
    "rakdos" => "br",
    "gruul" => "rg",
    "selesnya" => "gw",

    "boros" => "wr",
    "simic" => "ug",
    "orzhov" => "bw",
    "izzet" => "ru",
    "golgari" => "gb",

    "bant" => "gwu",
    "esper" => "wub",
    "grixis" => "ubr",
    "jund" => "brg",
    "naya" => "rgw",

    "abzan" => "wbg",
    "jeskai" => "urw",
    "sultai" => "bgu",
    "mardu" => "rwb",
    "temur" => "gur",
  }

  def self.color_indicator_name(indicator)
    names = {"w" => "white", "u" => "blue", "b" => "black", "r" => "red", "g" => "green"}
    color_indicator = names.map{|c,cv| indicator.include?(c) ? cv : nil}.compact
    case color_indicator.size
    when 5
      # It got removed with Sphinx of the Guildpact printing (RNA)
      nil
    when 1, 2
      color_indicator.join(" and ")
    when 3
      # Nicol Bolas from M19
      a, b, c = color_indicator
      "#{a}, #{b}, and #{c}"
    when 4
      # No such cards
      a, b, c, d = color_indicator
      "#{a}, #{b}, #{c}, and #{d}"
    when 0
      # devoid and Ghostfire - for some reason they use rules text, not color indicator
      # "colorless"
      nil
    end
  end
end
