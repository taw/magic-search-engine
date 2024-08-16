class ConditionCast < ConditionSimple
  def initialize(mana)
    @query_mana = parse_query_mana(mana.downcase)
  end

  def match?(card)
    return false unless card.mana_hash
    card.mana_hash.each do |m, _|
      case m
      when "w", "u", "b", "r", "g", "s", "c"
        return false unless @query_mana.include?(m)
      when "?", "x", "y", "z", "l", "d"
        # always OK
      when "2w", "2u", "2b", "2r", "2g"
        # always OK
      when /p/
        # always OK, you can just pay life
      when /\A[wubrgc][wubrgc]\z/
        return false unless @query_mana.include?(m[0]) or @query_mana.include?(m[1])
      else
        raise "Unknown mana type: #{m}"
      end
    end
    true
  end

  def to_s
    "cast:#{query_mana_to_s}"
  end

  private

  # Some of them make no sense
  def parse_query_mana(mana)
    pool = Hash.new(0)
    mana = mana.gsub(/\{(.*?)\}|(\d+)|([wubrgxyzchmnos])/) do
      if $1
        m = $1.downcase.tr("/{}", "")
        if m =~ /\A\d+\z/
          pool["?"] += m.to_i
        elsif m == "h"
          pool[m] += 1
        elsif m =~ /h/
          pool[m.sub("h", "").chars.sort.join] += 0.5
        elsif m != ""
          pool[m.chars.sort.join] += 1
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
end
