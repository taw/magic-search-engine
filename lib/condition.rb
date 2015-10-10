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
      return false unless card.block_code and card.block_name
      card.block_code.downcase == arg.downcase or text_query_match?(card.block_name, arg)
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
    when :format
      ["legal", "restricted"].include?(card.legality(arg))
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
    when :is_funny
      # There are some one off funny cards elsewhere
      %W[uh ug uqc].include?(card.set_code.downcase)
    when :is_timeshifted
      card.timeshifted and card.set_code.downcase == "pc"
    when :frame
      card.frame == arg
    when :border
      card.border == arg
    when :watermark
      card.watermark == arg
    when :mana
      match_mana?(card, *arg)
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
    name.downcase.gsub(/[Ææ]/, "ae").tr("Äàáâäèéêíõöúûü", "Aaaaaeeeioouuu").strip.split.join(" ")
  end

  def match_mana?(card, op, mana)
    query_mana = parse_query_mana(mana.downcase)
    card_mana = parse_card_mana(card.mana_cost)
    return false unless card_mana
    op = "==" if op == "="
    ["w", "u", "b", "r", "g", "c"].all? do |color|
      card_mana[color].send(op, query_mana[color])
    end
  end

  def parse_query_mana(mana)
    pool = Hash.new(0)
    mana = mana.gsub(/(\d+)|([wubrg])/) do
      if $1
        pool["c"] += $1.to_i
      else
        pool[$2] += 1
      end
      ""
    end
    raise "Mana query parse error: #{mana}" unless mana.empty?
    pool
  end

  def parse_card_mana(mana)
    return nil unless mana
    pool = Hash.new(0)

    mana = mana.gsub(/\{(.*?)\}/) do
      m = $1
      case m
      when /\A\d+\z/
        pool["c"] += m.to_i
      when /\A[wubrg]\z/
        pool[m] += 1
      when /\Ah([wubrg])\z/
        pool[$1] += 0.5
      when "x", "y", "z"
        # ignore
      when /\A([wubrg])\/([wubrg])\z/
        pool[m] += 1
      when /\A([wubrg])\/p\z/
        pool[m] += 1
      when /\A2\/([wubrg])\z/
        pool[m] += 1
      else
        raise "Unrecognized mana type: #{m}"
      end
      ""
    end
    raise "Mana query parse error: #{mana}" unless mana.empty?
    pool
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
    when "loyalty"
      card.loyalty
    when "year"
      card.year
    when /\A\d+\z/
      expr.to_i
    when /\A\d*\.\d+\z/
      expr.to_f
    when /\A(\d*)½\z/
      $1.to_i + 0.5
    else
      raise "Expr variable parse error: #{expr}"
    end
  end
end
