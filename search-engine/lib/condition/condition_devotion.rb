class ConditionDevotion < ConditionSimple
  include QueryManaToS

  def initialize(op, mana)
    @op = op
    @mana = mana
    @query_mana = parse_query_mana(mana.downcase)

    # we could add this warning:
    # warning %[devotion: query must only use same monocolored or hybrid mana symbol"]
  end

  # warning needs @logger, which we only get here, not in initialize
  def metadata!(key, value)
    super
    if key == :logger and @generic_mana
      warning %[Generic mana in "#{self}" is ignored, devotion only counts colored mana symbols]
    end
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

  # Devotion to one color is a plain integer count, totally ordered, so (unlike
  # mana cost, which compares a whole multiset) flipping the operator for negation
  # is correct here - "not (devotion >= 3)" really is "devotion < 3".
  OP_WORDS = {"=" => "is", "!=" => "isn't", ">=" => "is at least", "<=" => "is at most", ">" => "is more than", "<" => "is less than"}
  NEGATED_OP_WORDS = {"=" => "isn't", "!=" => "is", ">=" => "is less than", "<=" => "is more than", ">" => "is at most", "<" => "is at least"}

  # Almost always a single symbol ("devotion=bbb" is one clause: devotion to {b} is
  # 3); a query naming several symbols at once is a conjunction of independent
  # per-symbol comparisons under the hood, so negating that case doesn't get the
  # De Morgan treatment - same scope limit as everywhere else compound negation
  # would apply.
  def explain(negated: false)
    words = negated ? NEGATED_OP_WORDS : OP_WORDS
    @query_mana.map{|symbol, amount|
      "the devotion to {#{canonical_mana_symbol(symbol)}} #{words.fetch(@op, @op)} #{amount.to_i}"
    }.join(" and ")
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
    # generic mana doesn't count for devotion
    mana = mana.gsub(/\{(.*?)\}|\d+|([wubrgc])/) do
      if $1
        m = $1.downcase.tr("/{}ph", "").gsub(/\d/, "")
        if m != ""
          # {2/w} etc. still counts as one devotion to its color
          pool[m.chars.sort.join] += 1
        else
          @generic_mana = true
        end
      elsif $2
        pool[$2] += 1
      else
        @generic_mana = true
      end
      ""
    end
    raise "Mana query parse error: #{mana}" unless mana.empty?
    pool
  end
end
