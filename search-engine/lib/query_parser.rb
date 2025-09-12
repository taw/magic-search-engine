# Where's autoloader when we need it
require_relative "condition/condition"
require_relative "condition/condition_simple"
require_relative "condition/condition_format"
require_relative "condition/condition_print"
require_relative "condition/condition_regexp"
require_relative "condition/condition_or"
require_relative "condition/condition_in"
require_relative "condition/condition_set_type"
require_relative "condition/condition_nickname"
require_relative "condition/condition_oracle"
Dir["#{__dir__}/condition/condition_*.rb"].sort.each do |path| require_relative path end
require_relative "query_tokenizer"

class QueryParser
  def parse(query_string)
    str = query_string.strip

    # SQL injection bot protections
    # Just short circuit it here so we don't try to parse this crap
    if str.include?("/**/")
      return [nil, {}, ["Invalid query"]]
    end

    if str =~ /\A\s*(?:(?<flag1>\+\+|unique:prints)\s*)?!\s*(?<query>.*?)\s*(?:(?<flag2>\+\+|unique:prints))?\s*\z/
      name = $~["query"]
      if $~["flag1"] || $~["flag2"]
        metadata = {ungrouped: true}
      else
        metadata = {}
      end

      # These cards need special treatment:
      # * "Ach! Hans, Run!"
      # * Look at Me, I'm R&D
      # * R&D's Secret Lair
      # * Sword of Dungeons & Dragons
      # * "Rumors of My Death . . ."
      # * Minsc & Boo, Timeless Heroes
      unless name =~ /Ach.*Hans.*Run/i or name =~ /Rumors.*of.*My.*Death/i
        name = name.sub(/\A"(.*)"\z/) { $1 }
      end
      if name =~ %r[&|/] && name !~ /R&D|Dungeons\s*&\s*Dragons|Minsc\s*&|&\s*Boo/i
        cond = ConditionExactMultipart.new(name)
      else
        cond = ConditionExact.new(name)
      end
      [cond, metadata, []]
    else
      @tokens, @warnings = QueryTokenizer.new.tokenize(str)
      @metadata = {}
      query = parse_query
      normalize_metadata
      [query, @metadata, @warnings]
    end
  end

private

  def normalize_metadata
    sort_order = @metadata.delete(:sort)&.split(",") || ["default"]

    # Merge direction with sort
    case @metadata.delete(:direction)
    when "asc"
      # alredy fine
    when "desc"
      sort_order = sort_order.map do |s|
        s.start_with?("-") ? s[1..] : "-#{s}"
      end
    end
    # Resolve some aliases
    sort_order = sort_order.map do |s|
      {
        "cmc" => "mv",
        "-cmc" => "-mv",
        "pow" => "power",
        "-pow" => "-power",
        "tou" => "toughness",
        "-tou" => "-toughness",
        "rand" => "random",
        "-rand" => "random",
        "-random" => "random",
        "identity" => "ci",
        "-identity" => "-ci",
        "released" => "newall",
        "-oldall" => "newall",
        "-released" => "oldall",
        "-newall" => "oldall",
        "-new" => "old",
        "-old" => "new",
      }[s] || s
    end

    @metadata[:sort] = sort_order.join(",") if sort_order != ["default"]
  end

  def conds_to_query(conds)
    if conds.empty?
      nil
    elsif conds.size == 1
      conds[0]
    else
      ConditionAnd.new(*conds)
    end
  end

  def parse_query
    old_time, @time = @time, nil
    cond = parse_cond_list
    if @time
      printed_early = ConditionPrint.new("<=", @time)
      cond = conds_to_query([cond, printed_early])
      cond.metadata! :time, @time
      cond
    else
      cond
    end
  ensure
    @time = old_time
  end

  def parse_cond_list
    conds = []
    until @tokens.empty?
      case @tokens[0][0]
      when :close
        # Do not eat token
        break
      when :or
        @tokens.shift
        # This is optimization,
        #   Condition.new(:or, [conds, right_conds])
        # would work just as well
        if conds.empty?
          # Ignore
        else
          right_query = parse_cond_list
          if right_query
            return ConditionOr.new(conds_to_query(conds), right_query)
          else
            break
          end
        end
      when :slash_slash
        @tokens.shift
        # This is semantically meaningful
        left_query = conds_to_query(conds)
        right_query = parse_cond_list
        if left_query and right_query
          return ConditionPart.new(ConditionAnd.new(left_query, ConditionOther.new(right_query)))
        else
          query = left_query || right_query
          if query
            return ConditionPart.new(query)
          else
            return ConditionIsMultipart.new
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
    when :not, :other, :part, :related, :alt
      tok, = @tokens.shift
      cond = parse_cond
      if cond
        klass = Kernel.const_get("Condition#{tok.capitalize}")
        klass.new(cond)
      else
        # Parse error like "-)" or final "-"
        nil
      end
    when :or
      # Parse error like "- or"
      @tokens.shift
      parse_cond
    when :test
      @tokens.shift[1]
    when :metadata
      # Quietly eat it
      @metadata.merge!(@tokens.shift[1])
      parse_cond
    when :time
      # Quietly eat it, for now
      @warnings << "Multiple time: clauses in same subquery" if @time
      @time = @tokens.shift[1]
      parse_cond
    else
      @warnings << "Unknown token type #{@tokens.shift}"
      parse_cond
    end
  end
end
