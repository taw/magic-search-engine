class ConditionMana < ConditionSimple
  def initialize(op, mana)
    @op = op
    @query_mana = parse_query_mana(mana.downcase)
  end

  def match?(card)
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

  def to_s
    "mana#{@op}#{query_mana_to_s}"
  end

  private

  def query_mana_to_s
    res = []
    @query_mana.each do |m,c|
      c = c.to_i if c == c.to_i
      case m
      when "c"
        res << "#{c}"
      else
        if m =~ /\A[wubrg]\z/
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

  def parse_query_mana(mana)
    pool = Hash.new(0)
    mana = mana.gsub(/\{(.*?)\}|(\d+)|([wubrgxyz])/) do
      if $1
        m = normalize_mana_symbol($1)
        if m =~ /\A\d+\z/
          pool["c"] += m.to_i
        elsif m =~ /h/
          pool[m.sub("h", "")] += 0.5
        else
          pool[m] += 1
        end
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
end
