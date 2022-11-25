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

    "indatha" => "wbg",
    "ketria" => "gur",
    "raugrin" => "urw",
    "savai" => "rwb",
    "zagoth" => "bgu",
  }

  ColorCombinations = ["", "b", "bg", "bgr", "bgru", "bgruw", "bgrw", "bgu", "bguw", "bgw", "br", "bru", "bruw", "brw", "bu", "buw", "bw", "g", "gr", "gru", "gruw", "grw", "gu", "guw", "gw", "r", "ru", "ruw", "rw", "u", "uw", "w"].map{|c| c.chars.to_set}.to_set

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

  def self.matching(op, expr)
    expr = expr.downcase
    case expr
    when "*"
      # Useful just for color indicator queries
      # As "no indicator" is different from "colorless indicator"
      ColorCombinations
    when /\A\d+\z/
      target = expr.to_i
      ColorCombinations.select{|color|
        case op
        when "="
          color.size == target
        when ">="
          color.size >= target
        when ">"
          color.size > target
        when "<="
          color.size <= target
        when "<"
          color.size < target
        else
          raise "Expr comparison parse error: #{op}"
        end
      }.to_set
    when "ally", "allied"
      matching(op, "wu") |
      matching(op, "ub") |
      matching(op, "br") |
      matching(op, "rg") |
      matching(op, "gw")
    when "enemy"
      matching(op, "wb") |
      matching(op, "ur") |
      matching(op, "bg") |
      matching(op, "rw") |
      matching(op, "gu")
    when "shard"
      matching(op, "wub") |
      matching(op, "ubr") |
      matching(op, "brg") |
      matching(op, "rgw") |
      matching(op, "gwu")
    when "wedge"
      matching(op, "wur") |
      matching(op, "ubg") |
      matching(op, "brw") |
      matching(op, "rgu") |
      matching(op, "gwb")
    else
      # we can safely ignore c (colorless), c=c and c="" are the same thing
      target = (expr.chars & %W[w u b r g]).to_set
      if expr.include?("m")
        return matching(op, target.to_a.join).select{|c| c.size >= 2}.to_set
      end
      ColorCombinations.select{|color|
        case op
        when "="
          color == target
        when ">="
          color >= target
        when ">"
          color > target
        when "<="
          color <= target
        when "<"
          color < target
        else
          raise "Expr comparison parse error: #{op}"
        end
      }.to_set
    end
  end
end
