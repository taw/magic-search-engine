class Condition
  attr_reader :cond, :arg
  def initialize(cond, arg)
    @cond = cond
    @arg = arg
  end

  def match?(card)
    case cond
    when :colors
      match_colors?(card, arg.downcase)
    when :colors_exclusive
      match_colors_exclusive?(card, arg.downcase)
    when :color_identity
      match_color_identity?(card, arg.downcase)
    when :edition
      card.set_code.downcase == arg.downcase or text_query_match?(card.set_name, arg)
    when :block
      # warn "Blocks not supported"
      true
    when :types
      arg.downcase.split.all?{|type|
        card.types.include?(type)
      }
    when :exact
      normalize_name(card.name) == normalize_name(arg)
    when :word
      normalize_name(card.name).include?(normalize_name(arg))
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
      match_expr?(card, *arg)
    when :or
      arg.any?{|c| c.match?(card)}
    when :and
      arg.all?{|c| c.match?(card)}
    when :not
      not arg.match?(card)
    when :is_vanilla
      card.text == ""
    when :is_split
      card.layout == "split"
    when :is_permanent
      (card.types & ["instant", "sorcery"]).empty?
    when :is_spell
      (card.types & ["land"]).empty?
    when :is_old
      card.frame == "old"
    when :is_new
      card.frame == "new"
    when :is_future
      card.frame == "future"
    when :"is_black-bordered"
      card.border == "black"
    when :"is_silver-bordered"
      card.border == "silver"
    when :"is_white-bordered"
      card.border == "white"
    when :watermark
      card.watermark == arg
    else
      warn "Query error: #{cond} #{arg}"
      false
      # require 'pry'; binding.pry
    end
  end

  def inspect
    "#{cond}:#{arg.inspect}"
  end

  private

  def text_query_match?(text, query)
    normalize_name(text).include?(normalize_name(query))
  end

  def normalize_name(name)
    name.downcase.gsub(/[Ææ]/, "ae").strip.split.join(" ")
  end

  def match_colors?(card, colors_query)
    card_colors = card.colors
    colors_query.chars.any? do |q|
      case q
      when /\A[wubrg]\z/
        card_colors.include?(q)
      when "m"
        card_colors.size >= 2
      when "c"
        card_colors.size == 0 and not card.types.include?("land")
      when "l"
        # Dryad Arbor is not c:l
        card_colors.size == 0 and card.types.include?("land")
      end
    end
  end

  def match_colors_exclusive?(card, colors_query)
    return false unless match_colors?(card, colors_query)
    (card.colors - colors_query.chars).empty?
  end

  def match_color_identity?(card, colors)
    # Ignore "m"/"l" in query
    # Treat "cr" as "c"
    commander_ci = colors.gsub(/ml/, "").chars.uniq
    card_ci  = card.color_identity
    return card_ci == [] if commander_ci.include?("c")
    card_ci.all? do |color|
      commander_ci.include?(color)
    end
  end

  def match_expr?(card, a, op, b)
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
