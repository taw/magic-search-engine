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
        (o|oracle|ft|flavor|a|art|artist|n|name|number|rulings)
        \s*[:=]\s*
        /(
          (?:[^\\/]|\\.)*
        )/
        ]xi)
        begin
          cond = {
            "a" => ConditionArtistRegexp,
            "art" => ConditionArtistRegexp,
            "artist" => ConditionArtistRegexp,
            "ft" => ConditionFlavorRegexp,
            "flavor" => ConditionFlavorRegexp,
            "n" => ConditionNameRegexp,
            "name" => ConditionNameRegexp,
            "o" => ConditionOracleRegexp,
            "oracle" => ConditionOracleRegexp,
            "number" => ConditionNumberRegexp,
            "rulings" => ConditionRulingsRegexp,
          }[s[1].downcase] or raise "Internal Error: #{s[0]}"
          rx = Regexp.new(s[2], Regexp::IGNORECASE | Regexp::MULTILINE)
          tokens << [:test, cond.new(rx)]
        rescue RegexpError => e
          cond = {
            "a" => ConditionArtist,
            "art" => ConditionArtist,
            "artist" => ConditionArtist,
            "ft" => ConditionFlavor,
            "flavor" => ConditionFlavor,
            "n" => ConditionWord,
            "name" => ConditionWord,
            "o" => ConditionOracle,
            "oracle" => ConditionOracle,
            "number" => ConditionNumber,
            "rulings" => ConditionRulings,
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
      elsif s.scan(/(?:t|type)\s*[:=]\s*(?:"(.*?)"|([’'\-\u2212\p{L}\p{Digit}_\*]+))/i)
        tokens << [:test, ConditionTypes.new(s[1] || s[2])]
      elsif s.scan(/(?:ft|flavor)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionFlavor.new(s[1] || s[2])]
      elsif s.scan(/(?:fn)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+|\*))/i)
        tokens << [:test, ConditionFlavorName.new(s[1] || s[2])]
      elsif s.scan(/(?:o|oracle)\s*[:=]\s*(?:"(.*?)"|([^\s\)]+))/i)
        tokens << [:test, ConditionOracle.new(s[1] || s[2])]
      elsif s.scan(/(?:keyword)\s*[:=]\s*(?:"(.*?)"|([^\s\)]+))/i)
        tokens << [:test, ConditionKeyword.new(s[1] || s[2])]
      elsif s.scan(/(?:a|art|artist)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionArtist.new(s[1] || s[2])]
      elsif s.scan(/(?:rulings)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionRulings.new(s[1] || s[2])]
      elsif s.scan(/(cn|tw|fr|de|it|jp|kr|pt|ru|sp|cs|ct|foreign)\s*[:=]\s*(?:"(.*?)"|([^\s\)]+))/i)
        tokens << [:test, ConditionForeign.new(s[1], s[2] || s[3])]
      elsif s.scan(/any\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionAny.new(s[1] || s[2])]
      elsif s.scan(/(banned|restricted|legal)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_\-\*]+))/i)
        klass = Kernel.const_get("Condition#{s[1].capitalize}")
        tokens << [:test, klass.new(s[2] || s[3])]
      elsif s.scan(/(?:f|format)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_\-\*]+))/i)
        tokens << [:test, ConditionFormat.new(s[1] || s[2])]
      elsif s.scan(/(?:name|n)\s*(>=|>|<=|<|=|:)\s*(?:"(.*?)"|([\p{L}\p{Digit}_\-]+))/i)
        op = s[1]
        op = "=" if op == ":"
        tokens << [:test, ConditionNameComparison.new(op, s[2] || s[3])]
      elsif s.scan(/(?:e|set|edition)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        sets = [s[1] || s[2]]
        sets << (s[1] || s[2]) while s.scan(/,(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionEdition.new(*sets)]
      elsif s.scan(/number\s*(>=|>|<=|<|=|:)\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+|\*))/i)
        tokens << [:test, ConditionNumber.new(s[2] || s[3], s[1])]
      elsif s.scan(/(?:w|wm|watermark)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+|\*))/i)
        tokens << [:test, ConditionWatermark.new(s[1] || s[2])]
      elsif s.scan(/(?:lore)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+|\*))/i)
        tokens << [:test, ConditionLore.new(s[1] || s[2])]
      elsif s.scan(/deck\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_\-]+))/i)
        tokens << [:test, ConditionDeck.new(s[1] || s[2])]
      elsif s.scan(/(?:b|block)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        blocks = [s[1] || s[2]]
        blocks << (s[1] || s[2]) while s.scan(/,(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionBlock.new(*blocks)]
      elsif s.scan(/st\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionSetType.new(s[1] || s[2])]
      elsif s.scan(/(c|ci|color|id|ind|identity|indicator)\s*(>=|>|<=|<|=|:)\s*(?:"(\d+)"|(\d+))/i)
        kind = s[1].downcase
        kind = "c" if kind == "color"
        kind = "ind" if kind == "indicator"
        kind = "ci" if kind == "id"
        kind = "ci" if kind == "identity"
        cmp = s[2]
        cmp = "=" if cmp == ":"
        color = s[3] || s[4]
        tokens << [:test, ConditionColorCountExpr.new(kind, cmp, color)]
      elsif s.scan(/(?:c|color)\s*:\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionColors.new(parse_color(s[1] || s[2]))]
      elsif s.scan(/(?:ci|id|identity)\s*[:!]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionColorIdentity.new(parse_color(s[1] || s[2]))]
      elsif s.scan(/(?:ind|indicator)\s*:\s*\*/i)
        tokens << [:test, ConditionColorIndicatorAny.new]
      elsif s.scan(/(?:ind|indicator)\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        tokens << [:test, ConditionColorIndicator.new(parse_color(s[1] || s[2]))]
      elsif s.scan(/(print|firstprint|lastprint)\s*(>=|>|<=|<|=|:)\s*(?:"(.*?)"|([\-[\p{L}\p{Digit}_]+]+))/i)
        op = s[2]
        op = "=" if op == ":"
        klass = Kernel.const_get("Condition#{s[1].capitalize}")
        tokens << [:test, klass.new(op, s[3] || s[4])]
      elsif s.scan(/(?:r|rarity)\s*(>=|>|<=|<|=|:)\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
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
      elsif s.scan(/(c|ci|id|ind|color|identity|indicator)\s*(>=|>|<=|<|=|!)\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        kind = s[1].downcase
        kind = "c" if kind == "color"
        kind = "ci" if kind == "id"
        kind = "ci" if kind == "identity"
        kind = "ind" if kind == "indicator"
        cmp = s[2]
        cmp = "=" if cmp == "!"
        tokens << [:test, ConditionColorExpr.new(kind, cmp, parse_color(s[3] || s[4]))]
      elsif s.scan(/(?:mana|m)\s*(>=|>|<=|<|=|:|!=)\s*((?:[\dwubrgxyzchmnos]|\{.*?\})*)/i)
        op = s[1]
        op = "=" if op == ":"
        mana = s[2]
        tokens << [:test, ConditionMana.new(op, mana)]
      elsif s.scan(/(?:cast)\s*(?:=|:)\s*((?:[\dwubrgxyzchmnos]|\{.*?\})*)/i)
        tokens << [:test, ConditionCast.new(s[1])]
      elsif s.scan(/(is|not)\s*[:=]\s*(vanilla|spell|permanent|funny|timeshifted|colorshifted|reserved|multipart|promo|primary|secondary|front|back|commander|digital|reprint|fetchland|shockland|dual|fastland|bounceland|gainland|filterland|checkland|manland|creatureland|scryland|battleland|guildgate|karoo|painland|triland|canopyland|shadowland|storageland|tangoland|canland|phyrexian|hybrid|augment|unique|booster|draft|historic|holofoil|foilonly|nonfoilonly|foil|nonfoil|foilboth|brawler|keywordsoup|partner|oversized|spotlight|modal|textless|fullart|full|ante|custom|mainfront|buyabox|tricycleland|triome|racist)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        cond = s[2].capitalize
        cond = "Bounceland" if cond == "Karoo"
        cond = "Manland" if cond == "Creatureland"
        cond = "Battleland" if cond == "Tangoland"
        cond = "Canopyland" if cond == "Canland"
        cond = "Fullart" if cond == "Full"
        cond = "Triome" if cond == "Tricycleland"
        klass = Kernel.const_get("ConditionIs#{cond}")
        tokens << [:test, klass.new]
      elsif s.scan(/has:(partner|watermark|indicator)\b/)
        cond = s[1].capitalize
        klass = Kernel.const_get("ConditionHas#{cond}")
        tokens << [:test, klass.new]
      elsif s.scan(/(is|not|layout)\s*[:=]\s*(normal|leveler|vanguard|dfc|double-faced|modal-dfc|modaldfc|transform|token|split|flip|plane|scheme|phenomenon|meld|aftermath|adventure|saga|planar|augment|host)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        kind = s[2].downcase
        kind = "double-faced" if kind == "transform"
        kind = "double-faced" if kind == "dfc"
        kind = "modaldfc" if kind == "modal-dfc"
        # mtgjson v3 vs v4 differences
        kind = "planar" if kind == "plane"
        kind = "planar" if kind == "phenomenon"
        tokens << [:test, ConditionLayout.new(kind)]
      elsif s.scan(/(is|not|game)\s*[:=]\s*(paper|arena|mtgo|shandalar|xmage)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        cond = s[2].capitalize
        klass = Kernel.const_get("ConditionIs#{cond}")
        tokens << [:test, klass.new]
      elsif s.scan(/in\s*[:=]\s*(cs|ct|de|fr|it|jp|kr|pt|ru|sp|cn|tw)\b/i)
        tokens << [:test, ConditionInForeign.new(s[1].downcase)]
      elsif s.scan(/in\s*[:=]\s*(paper|arena|mtgo|shandalar|xmage|foil|nonfoil|booster)\b/i)
        cond = s[1].capitalize
        klass = Kernel.const_get("ConditionIn#{cond}")
        tokens << [:test, klass.new]
      elsif s.scan(/in\s*[:=]\s*(basic|common|uncommon|rare|mythic|special)\b/i)
        kind = s[1].downcase
        tokens << [:test, ConditionInRarity.new(kind)]
      elsif s.scan(/in\s*[:=]\s*(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        # This needs to be last after all other in:
        sets = [s[1] || s[2]]
        sets << (s[1] || s[2]) while s.scan(/,(?:"(.*?)"|([\p{L}\p{Digit}_]+))/i)
        sets = sets.map(&:downcase)

        # Does it look like a set type?
        # We have a list
        # Commented out things are also set codes so they take priority
        #
        # It's a bit awkward as both set lists and set types lists are in db
        # and we don't have access to it here
        set_types = [
          "2hg",
          # "arc",
          "archenemy",
          "booster",
          "box",
          # "cmd",
          # "cns",
          "commander",
          "conspiracy",
          "core",
          "dd",
          "deck",
          "duel deck",
          "duels",
          "ex",
          "expansion",
          "fixed",
          # "fnm", # this one doesn't have longer alternative form :-/
          "from the vault",
          "ftv",
          "funny",
          "judge gift",
          "masterpiece",
          "masters",
          "me",
          "memorabilia",
          "modern",
          "multiplayer",
          "pc",
          "pds",
          "planechase",
          "portal",
          "premium deck",
          "promo",
          "spellbook",
          "st",
          "standard",
          "starter",
          "std",
          "token",
          "treasure chest",
          "two-headed giant",
          "un",
          "unset",
          "vanguard",
          "wpn",
          "instore",
        ]

        if sets.size == 1 and set_types.include?(sets[0].tr("_", " "))
          tokens << [:test, ConditionInSetType.new(sets[0])]
        else
          tokens << [:test, ConditionInEdition.new(*sets)]
        end
      elsif s.scan(/(is|frame|not)\s*[:=]\s*(compasslanddfc|colorshifted|devoid|extendedart|legendary|miracle|mooneldrazidfc|nyxtouched|originpwdfc|sunmoondfc|tombstone)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionFrameEffect.new(s[2].downcase)]
      elsif s.scan(/(is|frame|not)\s*[:=]\s*(old|new|future|modern|m15)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionFrame.new(s[2].downcase)]
      elsif s.scan(/frame\s*[:=]\s*(?:"(.*?)"|([\.\p{L}\p{Digit}_]+))/i)
        frame = (s[1]||s[2]).downcase
        frame_types = %W[old new future modern m15]
        frame_effects = %W[compasslanddfc colorshifted devoid extendedart legendary miracle mooneldrazidfc nyxtouched originpwdfc sunmoondfc tombstone].sort
        @warnings << "Unknown frame: #{frame}. Known frame types are: #{frame_types.join(", ")}. Known frame effects are: #{frame_effects.join(", ")}."
      elsif s.scan(/(is|not)\s*[:=]\s*(black-bordered|silver-bordered|white-bordered)\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionBorder.new(s[2].sub("-bordered", "").downcase)]
      elsif s.scan(/(is|not)\s*[:=]\s*borderless\b/i)
        tokens << [:not] if s[1].downcase == "not"
        tokens << [:test, ConditionBorder.new("borderless")]
      elsif s.scan(/border\s*[:=]\s*(black|silver|white|none|borderless)\b/i)
        kind = s[1].downcase
        kind = "borderless" if kind == "none"
        tokens << [:test, ConditionBorder.new(kind)]
      elsif s.scan(/(?:sort|order)\s*[:=]\s*(?:"(.*?)"|([\-\,\.\p{L}\p{Digit}_]+))/i)
        # Warning will be generated by sorter
        tokens << [:metadata, {sort: (s[1]||s[2]).downcase}]
      elsif s.scan(/(?:view|display)\s*[:=]\s*(?:"(.*?)"|([\.\p{L}\p{Digit}_]+))/i)
        view = (s[1]||s[2]).downcase
        known_views = ["checklist", "full", "images", "text"]
        unless known_views.include?(view)
          @warnings << "Unknown view: #{view}. Known options are: #{known_views.join(", ")}, and default."
        end
        tokens << [:metadata, {view: view}]
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
    if Color::Names[color_text]
      Color::Names[color_text]
    else
      return color_text if color_text =~ /\A[wubrgcm]+\z/
      fixed = color_text.gsub(/[^wubrgcm]/, "")
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
