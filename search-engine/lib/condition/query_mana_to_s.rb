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
end
