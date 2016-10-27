class ConditionMana < ConditionSimple
  def initialize(op, mana)
    @op = op
    @query_mana = parse_query_mana(mana.downcase)
    @needs_resolution = !!(@query_mana.keys.join =~ /[mnoh]/)
  end

  def match?(card)
    card_mana = card.mana_hash
    return false unless card_mana
    if @needs_resolution
      q_mana = resolve_variable_mana(card_mana, @query_mana)
    else
      q_mana = @query_mana
    end
    cmps = (card_mana.keys | q_mana.keys).map{|color| [card_mana[color], q_mana[color]]}
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
      raise "Unrecognized comparison #{@op}"
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

  def parse_query_mana(mana)
    pool = Hash.new(0)
    mana = mana.gsub(/\{(.*?)\}|(\d+)|([wubrgxyzchmnohmno])/) do
      if $1
        m = normalize_mana_symbol($1)
        if m =~ /\A\d+\z/
          pool["?"] += m.to_i
        elsif m == "h"
          pool[m] += 1
        elsif m =~ /h/
          pool[m.sub("h", "")] += 0.5
        else
          pool[m] += 1
        end
      elsif $2
        pool["?"] += $2.to_i
      elsif $3
        pool[$3] += 1
      end
      ""
    end
    raise "Mana query parse error: #{mana}" unless mana.empty?
    pool
  end

  def resolve_variable_mana(card_mana, query_mana)
    card_mana = card_mana.sort_by {|key, value| [value, key]}.to_h
    query_mana = query_mana.sort_by {|key, value| [value, key]}.to_h
    q_mana = Hash.new(0)
    colors = %w(w u b r g c)
    hybrids = %w(uw bu br gr gw bw bg gu ru rw)

    query_mana.each do |color, count|
      case color
      when "m", "n", "o"
        matched = false
        card_mana.each do |card_color, card_count|
          if colors.include?(card_color) &&
            !q_mana.keys.include?(card_color) &&
            !query_mana.keys.include?(card_color)
            q_mana[card_color] = count
            matched = true
            break
          end
        end
        q_mana[color] = count unless matched
      when "h"
        matched = false
        card_mana.each do |card_color, card_count|
          if hybrids.include?(card_color) &&
            !q_mana.keys.include?(card_color) &&
            !query_mana.keys.include?(card_color)
            q_mana[card_color] = count
            matched = true
            break
          end
        end
        q_mana[color] = count unless matched
      else
        q_mana[color] = count
      end
    end
    q_mana
  end

  def normalize_mana_symbol(sym)
    sym.downcase.tr("/{}", "").chars.sort.join
  end
end
