# Where's autoloader when we need it
require_relative "condition/condition"
require_relative "condition/condition_simple"
require_relative "condition/condition_format"
require_relative "condition/condition_print"
Dir["#{__dir__}/condition/condition_*.rb"].sort.each do |path| require_relative path end
require_relative "query_tokenizer"

class QueryParser
  def parse(query_string)
    str = query_string.strip
    if str =~ /\A(\+\+)?!(.*)\z/
      if $1 == "++"
        metadata = {ungrouped: true}
      else
        metadata = {}
      end
      name = $2
      # These cards need special treatment:
      # * "Ach! Hans, Run!"
      # * Look at Me, I'm R&D
      # * R&D's Secret Lair
      unless name =~ /Ach.*Hans.*Run/
        name = name.sub(/\A"(.*)"\z/) { $1 }
      end
      if name =~ %r[&|/] && name !~ /R&D/
        cond = ConditionExactMultipart.new(name)
      else
        cond = ConditionExact.new(name)
      end
      [cond, metadata, []]
    else
      @tokens, @warnings = QueryTokenizer.new.tokenize(str)
      @metadata = {}
      query = parse_query
      [query, @metadata, @warnings]
    end
  end

private

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
      @warnings << "Unknown token type #{@tokens[0]}"
    end
  end
end
