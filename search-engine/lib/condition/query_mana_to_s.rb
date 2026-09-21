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
        if c.is_a?(Integer)
          c.times{ res << "{#{m}}" }
        elsif c % 1 == 0.5
          c.floor.times{ res << "{#{m}}" }
          res << "{h#{m}}"
        else
          # TOTALLY BOGUS, same as #query_mana_to_s
          res << "{#{m}=#{c}}"
        end
      end
    end
    res.sort.join
  end
end
