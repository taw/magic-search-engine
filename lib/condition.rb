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
    when :layout
      card.layout == arg
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
    when :other
      card.others and card.others.any?{|c| arg.match?(c)}
    when :part
      card.others and (arg.match?(card) or card.others.any?{|c| arg.match?(c)})
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
    cmps = (card_mana.keys | query_mana.keys).map{|color| [card_mana[color], query_mana[color]]}
    case op
    when ">="
      cmps.all?{|a,b| a>=b}
    when ">"
      cmps.all?{|a,b| a>=b} and not cmps.all?{|a,b| a==b}
    when "="
      cmps.all?{|a,b| a==b}
    when "<"
      cmps.all?{|a,b| a<=b} and not cmps.all?{|a,b| a==b}
    when "<="
      cmps.all?{|a,b| a<=b}
    else
      raise
    end
  end

  def parse_query_mana(mana)
    pool = Hash.new(0)
    mana = mana.gsub(/\{(.*?)\}|(\d+)|([wubrgxyz])/) do
      if $1
        pool[normalize_mana_symbol($1)] += 1
      elsif $2
        pool["c"] += $2.to_i
      else
        pool[$3] += 1
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
      when /\A[wubrgxyz]\z/
        # x is basically a color for this kind of queries
        pool[m] += 1
      when /\Ah([wubrg])\z/
        pool[$1] += 0.5
      when /\A([wubrg])\/([wubrg])\z/
        pool[normalize_mana_symbol(m)] += 1
      when /\A([wubrg])\/p\z/
        pool[normalize_mana_symbol(m)] += 1
      when /\A2\/([wubrg])\z/
        pool[normalize_mana_symbol(m)] += 1
      else
        raise "Unrecognized mana type: #{m}"
      end
      ""
    end
    raise "Mana query parse error: #{mana}" unless mana.empty?
    pool
  end

  def normalize_mana_symbol(sym)
    sym.downcase.tr("/{}", "").chars.sort.join
  end

  # c: system is rather illogical
  # This seems to be the logic as implemented
  def match_colors?(card, colors_query)
    card_colors = card.colors
    colors_query = colors_query.chars

    if colors_query.include?("c")
      return true if card_colors.size == 0 and not card.types.include?("land")
    end
    if colors_query.include?("l")
      # Dryad Arbor is not c:l
      return true if card_colors.size == 0 and card.types.include?("land")
    end
    if colors_query.include?("m")
      return false if card_colors.size <= 1
    end
    colors_query_actual_colors = colors_query - ["l", "c", "m"]
    if colors_query.include?("m") and colors_query_actual_colors == []
      return true
    end

    colors_query_actual_colors.any? do |q|
      case q
      when /\A[wubrg]\z/
        card_colors.include?(q)
      else
        raise "Unknown color: #{q}"
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
    return false if a.is_a?(String) != b.is_a?(String)
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
    when /\A-?\d+\z/
      expr.to_i
    when /\A-?\d*\.\d+\z/
      expr.to_f
    when /\A(-?\d*)½\z/
      # Negative half numbers never happen or real cards, but for sake of completeness
      if expr[0] == "-"
        $1.to_i - 0.5
      else
        $1.to_i + 0.5
      end
    else
      raise "Expr variable parse error: #{expr}"
    end
  end
end
