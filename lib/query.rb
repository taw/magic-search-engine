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
      if s.scan(/\s+/)
        # pass
      elsif s.scan(/and\b/i)
        # tokens << [:and]
      elsif s.scan(/or\b/i)
        tokens << [:or]
      elsif s.scan(/not/)
        tokens << [:not]
      elsif s.scan(/-/)
        tokens << [:not]
      elsif s.scan(/\(/)
        tokens << [:open]
      elsif s.scan(/\)/)
        tokens << [:close]
      elsif s.scan(/t:(?:"(.*?)"|(\w+))/i)
        tokens << [:types, s[1] || s[2]]
      elsif s.scan(/ft:(?:"(.*?)"|(\w+))/i)
        tokens << [:flavor, s[1] || s[2]]
      elsif s.scan(/o:(?:"(.*?)"|([\w\{\}]+))/i)
        tokens << [:oracle, s[1] || s[2]]
      elsif s.scan(/a:(?:"(.*?)"|(\w+))/i)
        tokens << [:artist, s[1] || s[2]]
      elsif s.scan(/(banned|restricted|legal):(\S+)/)
        tokens << [s[1].to_sym, s[2]]
      elsif s.scan(/e:(?:"(.*?)"|(\w+))/i)
        tokens << [:edition, s[1] || s[2]]
      elsif s.scan(/b:(?:"(.*?)"|(\S+))/i)
        tokens << [:block, s[1] || s[2]]
      elsif s.scan(/c:([wubrgcml]+)/i)
        tokens << [:colors, s[1]]
      elsif s.scan(/ci:([wubrgcml]+)/i)
        tokens << [:color_identity, s[1]]
      elsif s.scan(/c!([wubrgcml]+)/i)
        tokens << [:colors_exclusive, s[1]]
      elsif s.scan(/r:(\S+)/)
        tokens << [:rarity, s[1]]
      elsif s.scan(/(pow|tou|cmc)(>=|>|<=|<|=)(pow|tou|cmc|\d+)\b/)
        tokens << [:expr, [s[1], s[2], s[3]]]
      elsif s.scan(/is:(split|vanilla|spell|permanent)\b/)
        tokens << [:"is_#{s[1]}"]
      elsif s.scan(/"(.*?)"/)
        tokens << [:word, s[1]]
      elsif s.scan(/([^-!<>=:"\s]+)(?=\s|$)/i)
        # No special characters here
        tokens << [:word, s[1]]
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
    when :not
      @tokens.shift
      cond = parse_cond
      if cond
        Condition.new(:not, cond)
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
