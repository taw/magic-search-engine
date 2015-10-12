require "strscan"
require_relative "condition"

class Query
  def initialize(query_string)
    parse!(query_string)
    # p [query_string, @query]
  end

  def match?(card)
    @query.match?(card)
  end

private

  # Tokens are:
  # open, close, not, or, atom
  # and token is ignored as it does literally nothing
  def tokenize(str)
    tokens = []
    s = StringScanner.new(str)
    until s.eos?
      if s.scan(/[\s,]+/)
        # pass
      elsif s.scan(/and\b/i)
        # tokens << [:and]
      elsif s.scan(/or\b/i)
        tokens << [:or]
      elsif s.scan(/-/)
        tokens << [:not]
      elsif s.scan(/\(/)
        tokens << [:open]
      elsif s.scan(/\)/)
        tokens << [:close]
      elsif s.scan(/t:(?:"(.*?)"|([’'\-\u2212\w]+))/i)
        tokens << [:types, s[1] || s[2]]
      elsif s.scan(/ft:(?:"(.*?)"|(\w+))/i)
        tokens << [:flavor, s[1] || s[2]]
      elsif s.scan(/o:(?:"(.*?)"|([^\s\)]+))/i)
        tokens << [:oracle, s[1] || s[2]]
      elsif s.scan(/a:(?:"(.*?)"|(\w+))/i)
        tokens << [:artist, s[1] || s[2]]
      elsif s.scan(/(banned|restricted|legal):(\S+)/)
        tokens << [s[1].to_sym, s[2]]
      elsif s.scan(/e:(?:"(.*?)"|(\w+))/i)
        tokens << [:edition, s[1] || s[2]]
      elsif s.scan(/watermark:(?:"(.*?)"|(\w+))/i)
        tokens << [:watermark, s[1] || s[2]]
      elsif s.scan(/f:(?:"(.*?)"|(\w+))/i)
        tokens << [:format, s[1] || s[2]]
      elsif s.scan(/b:(?:"(.*?)"|(\S+))/i)
        tokens << [:block, s[1] || s[2]]
      elsif s.scan(/c:([wubrgcml]+)/i)
        tokens << [:colors, s[1]]
      elsif s.scan(/ci:([wubrgcml]+)/i)
        tokens << [:color_identity, s[1]]
      elsif s.scan(/c!([wubrgcml]+)/i)
        tokens << [:colors_exclusive, s[1]]
      elsif s.scan(/r:(\S+)/)
        tokens << [:rarity, s[1].downcase]
      elsif s.scan(/(pow|loyalty|tou|cmc|year)\s*(>=|>|<=|<|=)\s*(pow|tou|cmc|loyalty|year|-?\d+\.\d+|-?\.\d+|-?\d*½|-?\d+)\b/i)
        tokens << [:expr, [s[1], s[2], s[3]]]
      elsif s.scan(/mana\s*(>=|>|<=|<|=)\s*((?:[\dwubrgxyz]|\{.*?\})+)/i)
        tokens << [:mana, [s[1], s[2]]]
      elsif s.scan(/(is|not):(vanilla|spell|permanent|funny|timeshifted|reserved)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:"is_#{s[2]}"]
      elsif s.scan(/(is|not):(split|flip|dfc)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        layout = s[2]
        layout = "double-faced" if layout == "dfc"
        tokens << [:layout, layout]
      elsif s.scan(/layout:(normal|leveler|vanguard|dfc|token|split|flip|plane|scheme|phenomenon)/)
        layout = s[1]
        layout = "double-faced" if layout == "dfc"
        tokens << [:layout, layout]
      elsif s.scan(/(is|not):(old|new|future)\b/)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:frame, s[2].downcase]
      elsif s.scan(/(is|not):(black-bordered|silver-bordered|white-bordered)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:border, s[2].sub("-bordered", "").downcase]
      elsif s.scan(/"(.*?)"/)
        tokens << [:word, s[1]]
      elsif s.scan(/not/)
        tokens << [:not]
      elsif s.scan(/other:/)
        tokens << [:other]
      elsif s.scan(/part:/)
        tokens << [:part]
      elsif s.scan(/([^-!<>=:"\s][^!<>=:"\s]*)(?=\s|$)/i)
        # Veil-Cursed and similar silliness
        words = s[1].split("-")
        if words.size > 1
          tokens << [:open]
          words.each do |w|
            tokens << [:word, w]
          end
          tokens << [:close]
        else
          tokens << [:word, s[1]]
        end
      else
        warn "Query parse error: #{str}"
        s.scan(/(\S+)/)
        tokens << [:word, s[1]]
      end
    end
    tokens
  end

  def parse!(str)
    str = str.strip
    if str =~ /\A!(.*)\z/
      @query = Condition.new(:exact, $1)
    else
      @tokens = tokenize(str)
      @query = parse_query
    end
  end

  private

  def conds_to_query(conds)
    if conds.empty?
      nil
    elsif conds.size == 1
      conds[0]
    else
      Condition.new(:and, conds)
    end
  end

  def parse_query
    conds = []
    until @tokens.empty?
      case @tokens[0][0]
      when :close
        # Do ont eat token
        break
      when :or
        @tokens.shift
        # This is optimization,
        #   Condition.new(:or, [conds, right_conds])
        # would work just as well
        if conds.empty?
          # Ignore
        else
          right_query = parse_query
          if right_query
            return Condition.new(:or, [conds_to_query(conds), right_query])
          else
            break
          end
        end
      # includes open / not
      else
        subquery = parse_cond
        if subquery
          conds << subquery
        else
          break
        end
      end
    end
    conds_to_query(conds)
  end

  def parse_cond
    return nil if @tokens.empty?
    case @tokens[0][0]
    when :open
      @tokens.shift
      subquery = parse_query
      @tokens.shift if @tokens[0] == [:close] # Ignore mismatched
      subquery
    when :close
      return
    when :not, :other, :part
      tok, = @tokens.shift
      cond = parse_cond
      if cond
        Condition.new(tok, cond)
      else
        # Parse error like "-)" or final "-"
        nil
      end
    when :or
      # Parse error like "- or"
      @tokens.shift
      parse_cond
    else
      t, a = @tokens.shift
      Condition.new(t, a)
    end
  end
end
