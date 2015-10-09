require "strscan"

class Query
  def initialize(query_string)
    parse!(query_string)
  end

  def matches?(card)
    @query.all? do |type, arg|
      case type
      when :colors
        matches_colors?(card, arg.downcase)
      when :colors_exclusive
        matches_colors_exclusive?(card, arg.downcase)
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
        card.text.downcase.include?(arg.downcase)
      when :banned
        card.legality(arg) == "banned"
      when :restricted
        card.legality(arg) == "restricted"
      when :legal
        card.legality(arg) == "legal"
      when :rarity
        card.rarity == arg
      when :expr
        matches_expr?(card, *arg)
      else
        require 'pry'; binding.pry
        raise "Query error: #{type}"
      end
    end
  end
private

  def parse!(str)
    @query = []
    str = str.strip

    if str =~ /\A!(.*)\z/
      @query = [[:exact, $1]]
      return
    end

    s = StringScanner.new(str)
    until s.eos?
      if s.scan(/\s+/)
        # pass
      elsif s.scan(/([^!<>=:"]+)(?=\s|$)/i)
        # No special characters here
        @query << [:word, s[1]]
      elsif s.scan(/t:(?:"(.*?)"|(\S+))/i)
        @query << [:types, s[1] || s[2]]
      elsif s.scan(/ft:(?:"(.*?)"|(\S+))/i)
        @query << [:flavor, s[1] || s[2]]
      elsif s.scan(/o:(?:"(.*?)"|(\S+))/i)
        @query << [:oracle, s[1] || s[2]]
      elsif s.scan(/a:(?:"(.*?)"|(\S+))/i)
        @query << [:artist, s[1] || s[2]]
      elsif s.scan(/(banned|restricted|legal):(\S+)/)
        @query << [s[1].to_sym, s[2]]
      elsif s.scan(/c:([wubrgcml]+)/i)
        @query << [:colors, s[1]]
      elsif s.scan(/c!([wubrgcml]+)/i)
        @query << [:colors_exclusive, s[1]]
      elsif s.scan(/r:(\S+)/)
        @query << [:rarity, s[1]]
      elsif s.scan(/(pow|tou|cmc)(>=|>|<=|<|=)(pow|tou|cmc|\d+)\b/)
        @query << [:expr, [s[1], s[2], s[3]]]
      else
        warn "Query parse error: #{str}"
        s.scan(/(\S+)/)
        @query << [:word, s[1]]
      end
    end
  end

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
        colors.size == 0
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
