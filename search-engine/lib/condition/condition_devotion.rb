class ConditionDevotion < ConditionSimple
  def initialize(op, mana)
    @op = op
    @mana = mana
    @query_mana = parse_query_mana(mana.downcase)

    # warning %[devotion: query must only use same monocolored or hybrid mana symbol"]
  end

  def match?(card)
    return false if card.types.include?("instant") or card.types.include?("sorcery")

    @query_mana.all? do |symbol, query_amount|
      card_amount = devotion_to(card, symbol)

      case @op
      when ">="
        card_amount >= query_amount
      when ">"
        card_amount > query_amount
      when "="
        card_amount == query_amount
      when "!="
        card_amount != query_amount
      when "<"
        card_amount < query_amount
      when "<="
        card_amount <= query_amount
      else
        raise "Unrecognized comparison #{@op}"
      end
    end
  end

  def to_s
    "devotion#{@op}#{@mana}"
  end

  private

  def devotion_to(card, query_symbol)
    return 0 unless card.mana_hash

    total = 0

    card.mana_hash.each do |card_symbol, card_amount|
      if query_symbol.chars.any?{|qs| card_symbol.include?(qs) }
        total += card_amount
      end
    end

    total
  end

  def parse_query_mana(mana)
    pool = Hash.new(0)
    mana = mana.gsub(/\{(.*?)\}|(\d+)|([wubrgxyzchmno])/) do
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
