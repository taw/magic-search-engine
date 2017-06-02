require "strscan"

class QueryTokenizer
  def tokenize(str)
    tokens = []
    warnings = []
    s = StringScanner.new(str)
    until s.eos?
      if s.scan(/[\s,]+/i)
        # pass
      elsif s.scan(/and\b/i)
        # and is default, skip it
      elsif s.scan(/or\b/i)
        tokens << [:or]
      elsif s.scan(%r[(R&D\b)]i)
        # special case, not split cards
        tokens << [:test, ConditionWord.new(s[1])]
      elsif s.scan(%r[[/&]+]i)
        tokens << [:slash_slash]
      elsif s.scan(/-/i)
        tokens << [:not]
      elsif s.scan(/\(/i)
        tokens << [:open]
      elsif s.scan(/\)/i)
        tokens << [:close]
      elsif s.scan(/t:(?:"(.*?)"|([’'\-\u2212\w\*]+))/i)
        tokens << [:test, ConditionTypes.new(s[1] || s[2])]
      elsif s.scan(/ft:(?:"(.*?)"|(\w+))/i)
        tokens << [:test, ConditionFlavor.new(s[1] || s[2])]
      elsif s.scan(/o:(?:"(.*?)"|([^\s\)]+))/i)
        tokens << [:test, ConditionOracle.new(s[1] || s[2])]
      elsif s.scan(/a:(?:"(.*?)"|(\w+))/i)
        tokens << [:test, ConditionArtist.new(s[1] || s[2])]
      elsif s.scan(/(cn|tw|fr|de|it|jp|kr|pt|ru|sp|cs|ct):(?:"(.*?)"|([^\s\)]+))/i)
        tokens << [:test, ConditionForeign.new(s[1], s[2] || s[3])]
      elsif s.scan(/(banned|restricted|legal):(?:"(.*?)"|([\w\-]+))/i)
        klass = Kernel.const_get("Condition#{s[1].capitalize}")
        tokens << [:test, klass.new(s[2] || s[3])]
      elsif s.scan(/e:(?:"(.*?)"|(\w+))/i)
        sets = [s[1] || s[2]]
        sets << (s[1] || s[2]) while s.scan(/,(?:"(.*?)"|(\w+))/i)
        tokens << [:test, ConditionEdition.new(*sets)]
      elsif s.scan(/w:(?:"(.*?)"|(\w+|\*))/i)
        tokens << [:test, ConditionWatermark.new(s[1] || s[2])]
      elsif s.scan(/f:(?:"(.*?)"|([\w\-]+))/i)
        tokens << [:test, ConditionFormat.new(s[1] || s[2])]
      elsif s.scan(/b:(?:"(.*?)"|(\w+))/i)
        blocks = [s[1] || s[2]]
        blocks << (s[1] || s[2]) while s.scan(/,(?:"(.*?)"|(\w+))/i)
        tokens << [:test, ConditionBlock.new(*blocks)]
      elsif s.scan(/st:(?:"(.*?)"|(\w+))/i)
        tokens << [:test, ConditionSetType.new(s[1] || s[2])]
      elsif s.scan(/(?:c|color):([wubrgcml]+)/i)
        tokens << [:test, ConditionColors.new(s[1])]
      elsif s.scan(/(?:ci|id)[:!]([wubrgcml]+)/i)
        tokens << [:test, ConditionColorIdentity.new(s[1])]
      elsif s.scan(/(?:in):([wubrgcml]+)/i)
        tokens << [:test, ConditionColorIndicator.new(s[1])]
      elsif s.scan(/c!([wubrgcml]+)/i)
        tokens << [:test, ConditionColorsExclusive.new(s[1])]
      elsif s.scan(/(print|firstprint|lastprint)\s*(>=|>|<=|<|=)\s*(?:"(.*?)"|(\w+))/i)
        klass = Kernel.const_get("Condition#{s[1].capitalize}")
        tokens << [:test, klass.new(s[2], s[3] || s[4])]
      elsif s.scan(/r:(\w+)/i)
        tokens << [:test, ConditionRarity.new(s[1])]
      elsif s.scan(/(pow|loy|loyalty|tou|cmc|year)\s*(>=|>|<=|<|=)\s*(pow\b|tou\b|cmc\b|loy|loyalty\b|year\b|[²\d\.\-\*\+½]+)/i)
        tokens << [:test, ConditionExpr.new(s[1].downcase, s[2], s[3].downcase)]
      elsif s.scan(/(c|ci)\s*(>=|>|<=|<|=)\s*([wubrgc]*)/i)
        tokens << [:test, ConditionColorExpr.new(s[1].downcase, s[2], s[3].downcase)]
      elsif s.scan(/(?:mana|m)\s*(>=|>|<=|<|=|:|!=)\s*((?:[\dwubrgxyzchmno]|\{.*?\})*)/i)
        op = s[1]
        op = "=" if op == ":"
        mana = s[2]
        tokens << [:test, ConditionMana.new(op, mana)]
      elsif s.scan(/(is|not):(vanilla|spell|permanent|funny|timeshifted|colorshifted|reserved|multipart|promo|primary|commander|digital|reprint|fetchland|shockland)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        cond = s[2].capitalize
        cond = "Timeshifted" if cond == "Colorshifted"
        klass = Kernel.const_get("ConditionIs#{cond}")
        tokens << [:test, klass.new]
      elsif s.scan(/(is|not):(split|flip|dfc|meld|aftermath)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionLayout.new(s[2])]
      elsif s.scan(/layout:(normal|leveler|vanguard|dfc|double-faced|token|split|flip|plane|scheme|phenomenon|meld|aftermath)/i)
        tokens << [:test, ConditionLayout.new(s[1])]
      elsif s.scan(/(is|frame|not):(old|new|future)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionFrame.new(s[2].downcase)]
      elsif s.scan(/(is|not):(black-bordered|silver-bordered|white-bordered)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionBorder.new(s[2].sub("-bordered", "").downcase)]
      elsif s.scan(/border:(black|silver|white)\b/i)
        tokens << [:test, ConditionBorder.new(s[1].downcase)]
      elsif s.scan(/sort:(\w+)/i)
        tokens << [:metadata, {sort: s[1].downcase}]
      elsif s.scan(/view:(\w+)/i)
        tokens << [:metadata, {view: s[1].downcase}]
      elsif s.scan(/\+\+/i)
        tokens << [:metadata, {ungrouped: true}]
      elsif s.scan(/time:(?:"(.*?)"|([\.\w]+))/i)
        # Parsing is downstream responsibility
        tokens << [:time, parse_time(s[1] || s[2])]
      elsif s.scan(/"(.*?)"/i)
        tokens << [:test, ConditionWord.new(s[1])]
      elsif s.scan(/other:/i)
        tokens << [:other]
      elsif s.scan(/part:/i)
        tokens << [:part]
      elsif s.scan(/related:/i)
        tokens << [:related]
      elsif s.scan(/alt:/i)
        tokens << [:alt]
      elsif s.scan(/not\b/i)
        tokens << [:not]
      elsif s.scan(/([^-!<>=:"\s&\/()][^<>=:"\s&\/()]*)(?=$|[\s&\/()])/i)
        # Veil-Cursed and similar silliness
        words = s[1].split("-")
        if words.size > 1
          tokens << [:open]
          words.each do |w|
            tokens << [:test, ConditionWord.new(w)]
          end
          tokens << [:close]
        else
          tokens << [:test, ConditionWord.new(s[1])]
        end
      else
        # layout:fail, protection: etc.
        s.scan(/(\S+)/i)
        warnings << "Unrecognized token: #{s[1]}"
        tokens << [:test, ConditionWord.new(s[1])]
      end
    end
    [tokens, warnings]
  end

private

  def parse_time(time)
    time = time.downcase
    case time
    when /\A\d{4}\z/
      # It would probably be easier if we had end-of-period semantics, but we'd need to hack Date.parse for it
      # It parses "March 2010" as "2010.3.1"
      Date.parse("#{time}.1.1")
    when /\A\d{4}\.\d{1,2}\z/
      Date.parse("#{time}.1")
    when /\d{4}/
      # throw at Date.parse but only if not set name / symbol
      begin
        Date.parse(time)
      rescue
        time
      end
    else
      time
    end
  end
end
