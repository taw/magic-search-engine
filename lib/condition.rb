class Condition
  attr_reader :cond, :arg
  def initialize(cond, arg)
    @cond = cond
    @arg = arg
  end

  def match?(card)
    case cond
    when :colors
      matches_colors?(card, arg.downcase)
    when :colors_exclusive
      matches_colors_exclusive?(card, arg.downcase)
    when :color_identity
      require 'pry'; binding.pry
    when :edition
      require 'pry'; binding.pry
    when :block
      require "require 'pry'; binding.pry"
    when :types
      arg.downcase.split.all?{|type|
        card.types.include?(type)
      }
    when :exact
      normalize_name(card.name) == normalize_name(arg)
    when :word
      card.name.downcase.split.include?(arg.downcase)
    when :flavor
      card.flavor.downcase.include?(arg.downcase)
    when :artist
      card.artist.downcase.include?(arg.downcase)
    when :oracle
      card.text.downcase.include?(arg.gsub("~", card.name).downcase)
    when :banned
      card.legality(arg) == "banned"
    when :restricted
      card.legality(arg) == "restricted"
    when :legal
      card.legality(arg) == "legal"
    when :rarity
      card.rarity == arg.downcase
    when :expr
      matches_expr?(card, *arg)
    else
      require 'pry'; binding.pry
      raise "Query error: #{type}"
    end
  end

  private

  def normalize_name(name)
    name.downcase.strip.split.join(" ")
  end

  def matches_colors?(card, colors_query)
    colors = card.colors
    colors_query.chars.any? do |q|
      case q
      when "w"
        colors.include?("White")
      when "u"
        colors.include?("Blue")
      when "b"
        colors.include?("Black")
      when "r"
        colors.include?("Red")
      when "g"
        colors.include?("Green")
      when "m"
        colors.size >= 2
      when "c"
        colors.size == 0 and not card.types.include?("land")
      when "l"
        # Dryad Arbor is not c:l
        colors.size == 0 and card.types.include?("land")
      end
    end
  end

  def matches_colors_exclusive?(card, colors_query)
    return false unless matches_colors?(card, colors_query)
    return false if card.colors.include?("White") and colors_query !~ /w/
    return false if card.colors.include?("Blue") and colors_query !~ /u/
    return false if card.colors.include?("Black") and colors_query !~ /b/
    return false if card.colors.include?("Red") and colors_query !~ /r/
    return false if card.colors.include?("Green") and colors_query !~ /g/
    true
  end

  def matches_expr?(card, a, op, b)
    a = eval_expr(card, a)
    b = eval_expr(card, b)
    return false unless a and b
    case op
    when "="
      a == b
    when ">="
      a >= b
    when ">"
      a > b
    when "<="
      a <= b
    when "<"
      a < b
    else
      raise "Expr comparison parse error: #{op}"
    end
  end

  def eval_expr(card, expr)
    case expr
    when "pow"
      card.power
    when "tou"
      card.toughness
    when "cmc"
      card.cmc
    when /\A\d+\z/
      expr.to_i
    else
      raise "Expr variable parse error: #{expr}"
    end
  end
end
