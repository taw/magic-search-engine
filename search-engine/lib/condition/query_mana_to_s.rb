# Renders @query_mana back into query syntax, for conditions which parse a mana pool
module QueryManaToS
  private

  def query_mana_to_s
    res = []
    @query_mana.each do |m,c|
      c = c.to_i if c == c.to_i
      case m
      when "?"
        res << "#{c}"
      else
        if m =~ /\A[wubrgc]\z/
          mx = m
        else
          mx = "{#{m}}"
        end
        if c.is_a?(Integer)
          c.times{ res << mx }
        elsif c % 1 == 0.5
          c.floor.times{ res << mx }
          res << "{h#{m}}"
        else
          # TOTALLY BOGUS
          res << "{#{m}=#{c}}"
        end
      end
    end
    res.sort.join
  end

  # Same pool, but every symbol - including generic mana and bare colors, which
  # #query_mana_to_s leaves unbracketed since that's valid query syntax - goes in
  # {} so the frontend renders it as a mana symbol icon instead of bare text.
  # Variable symbols (m/n/o/h) get wrapped too, they just have no icon to show,
  # same as any other symbol the frontend doesn't recognize.
  def explain_mana_symbols(pool)
    res = []
    pool.each do |m, c|
      c = c.to_i if c == c.to_i
      case m
      when "?"
        res << "{#{c.to_i}}"
      else
        symbol = canonical_mana_symbol(m)
        if c.is_a?(Integer)
          c.times{ res << "{#{symbol}}" }
        elsif c % 1 == 0.5
          c.floor.times{ res << "{#{symbol}}" }
          res << "{h#{symbol}}"
        else
          # TOTALLY BOGUS, same as #query_mana_to_s
          res << "{#{symbol}=#{c}}"
        end
      end
    end
    res.sort.join
  end

  # @query_mana keys are built by sorting a symbol's letters alphabetically (order
  # doesn't matter for matching - "wb" and "bw" mean the same hybrid symbol), but
  # the frontend's mana-icon whitelist (and real cards) use a fixed, non-alphabetical
  # order per pair - {W/B}, {R/W}, {G/U}, not {B/W}/{W/R}/{U/G}. Unrecognized order
  # isn't just ugly, it's invisible to the icon renderer, which falls back to
  # printing the raw text. This maps the alphabetical form back to the printed one.
  CANONICAL_MANA_PAIRS = {
    "uw" => "wu", "bw" => "wb", "bu" => "ub", "ru" => "ur", "gr" => "rg",
    "pw" => "wp", "pu" => "up", "pr" => "rp",
    "bc" => "cb",
  }.freeze

  def canonical_mana_symbol(m)
    return CANONICAL_MANA_PAIRS.fetch(m, m) if m.size == 2
    if m.size == 3 && m.include?("p")
      pair = m.delete("p")
      return "#{CANONICAL_MANA_PAIRS.fetch(pair, pair)}p"
    end
    m
  end
end
