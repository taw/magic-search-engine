require "strscan"

class QueryTokenizer
  def tokenize(str)
    tokens = []
    @warnings = []
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
      elsif s.scan(%r[(\bDungeons\s*&\s*Dragons\b)]i)
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
      elsif s.scan(%r[
        (o|ft|a|n|name|number)
        \s*[:=]\s*
        /(
          (?:[^\\/]|\\.)*
        )/
        ]xi)
        begin
          cond = {
            "a"  => ConditionArtistRegexp,
            "ft" => ConditionFlavorRegexp,
            "n"  => ConditionNameRegexp,
            "name"  => ConditionNameRegexp,
            "o"  => ConditionOracleRegexp,
            "number"  => ConditionNumberRegexp,
          }[s[1].downcase] or raise "Internal Error: #{s[0]}"
          rx = Regexp.new(s[2], Regexp::IGNORECASE)
          tokens << [:test, cond.new(rx)]
        rescue RegexpError => e
          cond = {
            "a"  => ConditionArtist,
            "ft" => ConditionFlavor,
            "n"  => ConditionWord,
            "name" => ConditionWord,
            "o"  => ConditionOracle,
            "number"  => ConditionNumber,
          }[s[1].downcase] or raise "Internal Error: #{s[0]}"
          @warnings << "bad regular expression in #{s[0]} - #{e.message}"
          tokens << [:test, cond.new(s[2])]
        end
      elsif s.scan(%r[
        (cn|tw|fr|de|it|jp|kr|pt|ru|sp|cs|ct|foreign)
        \s*[:=]\s*
        /(
          (?:[^\\/]|\\.)*
        )/
        ]xi)
        begin
          # Denormalization is highly questionable here
          rxstr = s[2].unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase
          rx = Regexp.new(rxstr, Regexp::IGNORECASE)
          tokens << [:test, ConditionForeignRegexp.new(s[1], rx)]
        rescue RegexpError => e
          @warnings << "bad regular expression in #{s[0]} - #{e.message}"
          tokens << [:test, ConditionForeign.new(s[1], s[2])]
        end
      elsif s.scan(/t\s*[:=]\s*(?:"(.*?)"|([’'\-\u2212\p{L}\p{Digit}_\*]+))/i)
        tokens << [:test, ConditionTypes.new(s[1] || s[2])]
      elsif s.scan(/ft\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionFlavor.new(s[1] || s[2])]
      elsif s.scan(/o\s*[:=]\s*(?:"(.*?)"|([^\s\)]+))/i)
        tokens << [:test, ConditionOracle.new(s[1] || s[2])]
      elsif s.scan(/a\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionArtist.new(s[1] || s[2])]
      elsif s.scan(/(cn|tw|fr|de|it|jp|kr|pt|ru|sp|cs|ct|foreign)\s*[:=]\s*(?:"(.*?)"|([^\s\)]+))/i)
        tokens << [:test, ConditionForeign.new(s[1], s[2] || s[3])]
      elsif s.scan(/any\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionAny.new(s[1] || s[2])]
      elsif s.scan(/(banned|restricted|legal)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_\-]+))/i)
        klass = Kernel.const_get("Condition#{s[1].capitalize}")
        tokens << [:test, klass.new(s[2] || s[3])]
      elsif s.scan(/(?:name|n)\s*(>=|>|<=|<|=|:)\s*(?:"(.*?)"|([\p{L}\p{Digit}_\-]+))/i)
        op = s[1]
        op = "=" if op == ":"
        tokens << [:test, ConditionNameComparison.new(op, s[2] || s[3])]
      elsif s.scan(/(?:e|set)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        sets = [s[1] || s[2]]
        sets << (s[1] || s[2]) while s.scan(/,(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionEdition.new(*sets)]
      elsif s.scan(/number\s*(>=|>|<=|<|=|:)\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+|\*))/i)
        tokens << [:test, ConditionNumber.new(s[2] || s[3], s[1])]
      elsif s.scan(/w\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+|\*))/i)
        tokens << [:test, ConditionWatermark.new(s[1] || s[2])]
      elsif s.scan(/f\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_\-]+))/i)
        tokens << [:test, ConditionFormat.new(s[1] || s[2])]
      elsif s.scan(/deck\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_\-]+))/i)
        tokens << [:test, ConditionDeck.new(s[1] || s[2])]
      elsif s.scan(/b\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        blocks = [s[1] || s[2]]
        blocks << (s[1] || s[2]) while s.scan(/,(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionBlock.new(*blocks)]
      elsif s.scan(/st\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionSetType.new(s[1] || s[2])]
      elsif s.scan(/(c|ci|in)\s*(>=|>|<=|<|=)\s*(?:"(\d+)"|(\d+))/i)
        tokens << [:test, ConditionColorCountExpr.new(s[1].downcase, s[2], s[3] || s[4])]
      elsif s.scan(/(?:c|color)\s*:\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionColors.new(parse_color(s[1] || s[2]))]
      elsif s.scan(/(?:ci|id)\s*[:!]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionColorIdentity.new(parse_color(s[1] || s[2]))]
      elsif s.scan(/(?:in)\s*:\s*\*/i)
        tokens << [:test, ConditionColorIndicatorAny.new]
      elsif s.scan(/(?:in)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionColorIndicator.new(parse_color(s[1] || s[2]))]
      elsif s.scan(/c!(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionColorsExclusive.new(parse_color(s[1] || s[2]))]
      elsif s.scan(/(print|firstprint|lastprint)\s*(>=|>|<=|<|=|:)\s*(?:"(.*?)"|([\-[\p{L}\p{Digit}_]+]+))/i)
        op = s[2]
        op = "=" if op == ":"
        klass = Kernel.const_get("Condition#{s[1].capitalize}")
        tokens << [:test, klass.new(op, s[3] || s[4])]
      elsif s.scan(/r\s*(>=|>|<=|<|=|:)\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        op = s[1]
        op = "=" if op == ":"
        rarity = s[2] || s[3]
        begin
          tokens << [:test, ConditionRarity.new(op, rarity)]
        rescue
          @warnings << "unknown rarity: #{rarity}"
        end
      elsif s.scan(/(pow|power|loy|loyalty|tou|toughness|cmc|year)\s*(>=|>|<=|<|=|:)\s*(pow\b|power\b|tou\b|toughness\b|cmc\b|loy\b|loyalty\b|year\b|[²\d\.\-\*\+½x∞\?]+)/i)
        aliases = {"power" => "pow", "loyalty" => "loy", "toughness" => "tou"}
        a = s[1].downcase
        a = aliases[a] || a
        op = s[2]
        op = "=" if op == ":"
        b = s[3].downcase
        b = aliases[b] || b
        tokens << [:test, ConditionExpr.new(a, op, b)]
      elsif s.scan(/(c|ci|in)\s*(>=|>|<=|<|=)\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionColorExpr.new(s[1].downcase, s[2], parse_color(s[3] || s[4]))]
      elsif s.scan(/(?:mana|m)\s*(>=|>|<=|<|=|:|!=)\s*((?:[\dwubrgxyzchmno]|\{.*?\})*)/i)
        op = s[1]
        op = "=" if op == ":"
        mana = s[2]
        tokens << [:test, ConditionMana.new(op, mana)]
      elsif s.scan(/(is|not)\s*[:=]\s*(vanilla|spell|permanent|funny|timeshifted|colorshifted|reserved|multipart|promo|primary|secondary|front|back|commander|digital|reprint|fetchland|shockland|dual|fastland|bounceland|gainland|filterland|checkland|manland|scryland|battleland|guildgate|augment|unique|booster|draft|historic|holofoil|foilonly|nonfoilonly|foil|nonfoil|foilboth|brawler|keywordsoup|partner|oversized)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        cond = s[2].capitalize
        klass = Kernel.const_get("ConditionIs#{cond}")
        tokens << [:test, klass.new]
      elsif s.scan(/has:partner\b/)
      tokens << [:test, ConditionHasPartner.new]
      elsif s.scan(/(is|not|layout)\s*[:=]\s*(normal|leveler|vanguard|dfc|double-faced|token|split|flip|plane|scheme|phenomenon|meld|aftermath|saga|planar)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionLayout.new(s[2])]
      elsif s.scan(/(is|frame|not)\s*[:=]\s*(compasslanddfc|colorshifted|devoid|legendary|miracle|mooneldrazidfc|nyxtouched|originpwdfc|sunmoondfc|tombstone)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionFrameEffect.new(s[2].downcase)]
      elsif s.scan(/(is|frame|not)\s*[:=]\s*(old|new|future|modern|m15)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionFrame.new(s[2].downcase)]
      elsif s.scan(/(is|not)\s*[:=]\s*(black-bordered|silver-bordered|white-bordered)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionBorder.new(s[2].sub("-bordered", "").downcase)]
      elsif s.scan(/(is|not)\s*[:=]\s*borderless\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionBorder.new("none")]
      elsif s.scan(/border\s*[:=]\s*(black|silver|white|none)\b/i)
        tokens << [:test, ConditionBorder.new(s[1].downcase)]
      elsif s.scan(/(?:sort|order)\s*[:=]\s*(?:"(.*?)"|([\-\,\.\p{L}\p{Digit}_]+))/i)
        tokens << [:metadata, {sort: (s[1]||s[2]).downcase}]
      elsif s.scan(/view\s*[:=]\s*(?:"(.*?)"|([\.\p{L}\p{Digit}_]+))/i)
        tokens << [:metadata, {view: (s[1]||s[2]).downcase}]
      elsif s.scan(/\+\+/i)
        tokens << [:metadata, {ungrouped: true}]
      elsif s.scan(/time\s*[:=]\s*(?:"(.*?)"|([\.\p{L}\p{Digit}_]+))/i)
        # Parsing is downstream responsibility
        tokens << [:time, parse_time(s[1] || s[2])]
      elsif s.scan(/"(.*?)"/i)
        tokens << [:test, ConditionWord.new(s[1])]
      elsif s.scan(/other\s*[:=]\s*/i)
        tokens << [:other]
      elsif s.scan(/part\s*[:=]\s*/i)
        tokens << [:part]
      elsif s.scan(/related\s*[:=]\s*/i)
        tokens << [:related]
      elsif s.scan(/alt\s*[:=]\s*/i)
        tokens << [:alt]
      elsif s.scan(/not\b/i)
        tokens << [:not]
      elsif s.scan(/\*/i)
        # A quick hack, maybe add ConditionAll ?
        tokens << [:test, ConditionTypes.new("*")]
      elsif s.scan(/([^-!<>=:"\s&\/()][^<>=:"\s&\/()]*)(?=$|[\s&\/()])/i)
        # Veil-Cursed and similar silliness
        tokens << [:test, ConditionWord.new(s[1].gsub("-", " "))]
      else
        # layout:fail, protection: etc.
        s.scan(/(\S+)/i)
        @warnings << "Unrecognized token: #{s[1]}"
        tokens << [:test, ConditionWord.new(s[1])]
      end
    end
    [tokens, @warnings]
  end

private

  def parse_color(color_text)
    color_text = color_text.downcase
    return color_text if color_text =~ /\A[wubrgcml]+\z/
    case color_text
    when "white"
      "w"
    when "blue"
      "u"
    when "black"
      "b"
    when "red"
      "r"
    when "green"
      "g"
    else
      fixed = color_text.gsub(/[^wubrgcml]/, "")
      @warnings << "Unrecognized color query: #{color_text.inspect}, correcting to #{fixed.inspect}"
      fixed
    end
  end

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
