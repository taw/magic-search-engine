require "strscan"
require_relative "condition"

class Query
  def initialize(query_string)
    parse!(query_string)
  end

  def match?(card)
    @query.all? do |cond|
      cond.match?(card)
    end
  end

private

  # Tokens are:
  # open, close, not, and, or, atom
  def tokenize(str)
    tokens = []
    s = StringScanner.new(str)
    until s.eos?
      if s.scan(/\s+/)
        # pass
      elsif s.scan(/and\b/i)
        tokens << [:and]
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
      elsif s.scan(/t:(?:"(.*?)"|(\S+))/i)
        tokens << [:types, s[1] || s[2]]
      elsif s.scan(/ft:(?:"(.*?)"|(\S+))/i)
        tokens << [:flavor, s[1] || s[2]]
      elsif s.scan(/o:(?:"(.*?)"|(\S+))/i)
        tokens << [:oracle, s[1] || s[2]]
      elsif s.scan(/a:(?:"(.*?)"|(\S+))/i)
        tokens << [:artist, s[1] || s[2]]
      elsif s.scan(/(banned|restricted|legal):(\S+)/)
        tokens << [s[1].to_sym, s[2]]
      elsif s.scan(/e:(?:"(.*?)"|(\S+))/i)
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
      elsif s.scan(/([^-!<>=:"]+)(?=\s|$)/i)
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
    @query = []
    str = str.strip
    if str =~ /\A!(.*)\z/
      @query = [Condition.new(:exact, $1)]
      return
    end
    tokens = tokenize(str)
    @query = tokens.map{|c,a| Condition.new(c,a)}
  end
end
