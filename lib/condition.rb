# This class is just asking to be turned into a class hierarchy
class Condition
  attr_reader :cond, :arg
  def initialize(cond, arg)
    @cond = cond
    @msg  = :"match_#{cond}?"
    @arg = arg
    case @cond
    when :colors, :colors_exclusive
      @colors_query = @arg.downcase.chars
      @colors_c = @colors_query.include?("c")
      @colors_l = @colors_query.include?("l")
      @colors_m = @colors_query.include?("m")
      @colors_query_actual_colors = @colors_query - ["l", "c", "m"]
    when :color_identity
      # Ignore "m"/"l" in query
      # Treat "cr" as "c"
      @commander_ci = @arg.gsub(/ml/, "").chars.uniq
    when :mana
      @op, mana = *arg
      @query_mana = parse_query_mana(mana.downcase)
    when :artist, :flavor, :rarity
      @arg = @arg.downcase
    when :block
      @arg = normalize_text(@arg)
      @block_cache = Hash.new do |ht, set|
        ht[set] = set.match_block?(@arg)
      end
    when :edition
      @arg = normalize_text(@arg)
      @edition_cache = Hash.new do |ht, set|
        ht[set] = set.match_set?(@arg)
      end
    when :format, :legal, :banned, :restricted
      @arg = @arg.downcase
      @arg = "commander" if @arg == "edh"
    when :types
      @arg = @arg.downcase.tr("’\u2212", "'-").split.map do |type|
        if type == "urza" # type line stemming ...
          "urza's"
        else
          type
        end
      end
    end
  end

  def match?(card)
    send(@msg, card)
  end

  # c: system is rather illogical
  # This seems to be the logic as implemented
  def match_colors?(card)
    card_colors = card.colors.chars
    return true if @colors_c and card_colors.size == 0 and not card.types.include?("land")
    # Dryad Arbor is not c:l
    return true if @colors_l and card_colors.size == 0 and card.types.include?("land")
    return false if @colors_m and card_colors.size <= 1
    return true if @colors_m and @colors_query_actual_colors.empty?
    @colors_query_actual_colors.any? do |q|
      raise "Unknown color: #{q}" unless q =~ /\A[wubrg]\z/
      card_colors.include?(q)
    end
  end
  def match_colors_exclusive?(card)
    match_colors?(card) and (card.colors.chars - @colors_query).empty?
  end
  def match_color_identity?(card)
    card_ci  = card.color_identity.chars
    return card_ci == [] if @commander_ci.include?("c")
    card_ci.all? do |color|
      @commander_ci.include?(color)
    end
  end
  def match_edition?(card)
    @edition_cache[card.set]
  end
  def match_block?(card)
    @block_cache[card.set]
  end
  def match_types?(card)
    @arg.all?{|type|
      card.types.include?(type)
    }
  end
  def match_exact?(card)
    query_name = arg
    if query_name =~ %r[&|/]
      return false unless card.names
      query_parts = query_name.split(%r[(?:&|/)+]).map{|n| normalize_name(n)}
      card_parts  = card.names.map{|n| normalize_name(n)}
      (query_parts - card_parts).empty?
    else
      normalize_name(card.name) == normalize_name(query_name)
    end
  end
  def match_word?(card)
    normalize_name(card.name).include?(normalize_name(arg))
  end
  def match_flavor?(card)
    card.flavor.downcase.include?(@arg)
  end
  def match_artist?(card)
    card.artist.downcase.include?(@arg)
  end
  def match_oracle?(card)
    normalize_text(card.text).include?(normalize_text(@arg.gsub("~", card.name)))
  end
  def match_format?(card)
    legality = card.legality[@arg]
    legality == "legal" or legality == "restricted"
  end
  def match_banned?(card)
    card.legality[@arg] == "banned"
  end
  def match_restricted?(card)
    card.legality[@arg] == "restricted"
  end
  def match_legal?(card)
    card.legality[@arg] == "legal"
  end
  def match_rarity?(card)
    card.rarity == @arg
  end
  def match_expr?(card)
    a, op, b = *arg
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
  def match_or?(card)
    arg.any?{|c| c.match?(card)}
  end
  def match_and?(card)
    arg.all?{|c| c.match?(card)}
  end
  def match_not?(card)
    not arg.match?(card)
  end
  def match_is_vanilla?(card)
    card.text == ""
  end
  def match_is_multipart?(card)
    card.has_multiple_parts?
  end
  def match_layout?(card)
    card.layout == arg
  end
  def match_is_permanent?(card)
    (card.types & ["instant", "sorcery"]).empty?
  end
  def match_is_spell?(card)
    not card.types.include?("land")
  end
  def match_is_funny?(card)
    # There are some one off funny cards elsewhere
    %W[uh ug uqc].include?(card.set_code.downcase)
  end
  def match_is_timeshifted?(card)
    card.timeshifted and card.set_code.downcase == "pc"
  end
  def match_frame?(card)
    card.frame == arg
  end
  def match_border?(card)
    card.border == arg
  end
  def match_watermark?(card)
    card.watermark == arg
  end
  def match_mana?(card)
    card_mana = parse_card_mana(card.mana_cost)
    return false unless card_mana
    cmps = (card_mana.keys | @query_mana.keys).map{|color| [card_mana[color], @query_mana[color]]}
    case @op
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
  def match_other?(card)
    card.others and card.others.any?{|c| arg.match?(c)}
  end
  def match_part?(card)
    card.others and (arg.match?(card) or card.others.any?{|c| arg.match?(c)})
  end
  def match_is_reserved?(card)
    card.reserved
  end

  def inspect
    "#{cond}:#{arg.inspect}"
  end

  private

  def text_query_match?(text, query)
    normalize_name(text).include?(normalize_name(query))
  end

  def normalize_text(text)
    text.downcase.gsub(/[Ææ]/, "ae").tr("Äàáâäèéêíõöúûü’\u2212", "Aaaaaeeeioouuu'-").strip
  end

  def normalize_name(name)
    normalize_text(name).split.join(" ")
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
