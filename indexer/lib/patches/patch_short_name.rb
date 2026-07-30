# Old templating always used a card's full name when it referred to itself:
#   Lightning Bolt deals 3 damage to any target.
# New templating often says "this creature" instead (ConditionOracle::SELF_REFERENCE
# knows about those), and on legendary cards it usually uses a shortened name:
#   Ajani deals 3 damage to any target.  (Ajani Vengeant)
#   where X is Agatha's power            (Agatha of the Vile Cauldron)
#   put a +1/+1 counter on Dr. Crusher   (Dr. Beverly Crusher)
#
# Which part of the name survives isn't predictable, so instead of guessing we read
# it off the card: the short name is the longest run of words in the Oracle text
# which is an in-order subsequence of the name's words, starting at the first one.
#
# That's all o:"~" needs. A card which never calls itself by a short name simply
# doesn't have one as far as we're concerned.
class PatchShortName < Patch
  WORD_RX = %r{[\p{L}\p{N}][\p{L}\p{N}'’\-/]*|&}

  # A capital letter here is just a new sentence, not a continuing name
  SENTENCE_BREAK_RX = /[.!?;:—•"”\n()]/

  # Not names, no matter how they're capitalized
  FUNCTION_WORDS = %w[The A An It This That All]

  # Anything needing more context than this patch has
  OVERRIDES = {
    "Space Beleren" => nil, # "Space sculptor" is an ability word
    # mtgjson drops the "and" from the second mention, the printed card doesn't
    "Myojin of Night's Reach and Grim Betrayal" => nil,
  }

  def call
    creature_types # before we start iterating

    each_printing do |card|
      short_name = short_name_for(card)
      card["short_name"] = short_name if short_name
    end
  end

  private

  def short_name_for(card)
    return OVERRIDES[card["name"]] if OVERRIDES.key?(card["name"])
    return nil unless (card["supertypes"] || []).include?("Legendary")
    text = card["text"] or return nil
    name = card["name"].sub(" (Alchemy)", "")
    return nil if words(name).size < 2

    candidates = self_references(name, text)
      .reject{|full_name, _| full_name}
      .map(&:last)
      .uniq
      .reject{|short| noise?(short) }
    candidates.max_by{|short| words(short).size }
  end

  # Every way the text refers to itself, as [is it the full name?, name used]
  def self_references(name, text)
    name_spans = word_spans(name)
    name_words = name_spans.map(&:first)
    # Reminder text names other cards - "(Transforms from Storm the Vault.)"
    text_spans = word_spans(text.gsub(/\(.*?\)/m){ " " * $&.size })

    result = []
    i = 0
    while i < text_spans.size
      unless same_word?(name_words[0], text_spans[i][0])
        i += 1
        next
      end

      # Take as many of the name's words, in order, as the text keeps providing
      used = [0]
      wanted = 1
      j = i + 1
      while j < text_spans.size
        k = (wanted...name_words.size).find{|x| same_word?(name_words[x], text_spans[j][0]) }
        break unless k
        used << k
        wanted = k + 1
        j += 1
      end
      # Decide this before trimming, or a name ending in a lowercase word gets
      # trimmed into a short name it doesn't have (Commander Greven il-Vec)
      full_name = (used.size == name_words.size)
      # "Aang and" is not a short name for "Aang and La, Ocean's Fury"
      used.pop while used.size > 1 and name_words[used.last] !~ /\A[\p{Lu}\p{N}&]/
      # Matched text words are text_spans[i..last], one per name word we kept
      last = i + used.size - 1

      result << [full_name, rebuild(name, name_spans, used)] unless
        ability_word?(text, text_spans, last) or
        other_name?(name_words, used, text, text_spans, j)
      i = j
    end
    result
  end

  # An ability word looks just like a name, and sometimes contains one:
  #   "Blade of Magnus — Whenever Magnus the Red deals combat damage ..."
  # This rejects the occurrence rather than the card, so modes which happen to
  # repeat a real short name ("• Typhoid Mary — Draw a card.") still count.
  def ability_word?(text, text_spans, last)
    text[text_spans[last][2]..].start_with?(" — ")
  end

  # If the name in the text runs past anything the card's own name explains, it's
  # a different name which merely starts the same way:
  #   Icingdeath, Frost Tyrant -> "create Icingdeath, Frost Tongue, a legendary ..."
  #   Titania, Voice of Gaea   -> "meld them into Titania, Gaea Incarnate"
  #   Tuktuk the Explorer      -> "create Tuktuk the Returned, a legendary ..."
  #
  # This looks at the word which stopped the match, not at the end of what we kept -
  # "Tuktuk the" gets trimmed back to "Tuktuk", but it's "Returned" that gives it away.
  def other_name?(name_words, used, text, text_spans, j)
    return false if used.size == name_words.size
    return false if j >= text_spans.size
    return false unless text_spans[j][0] =~ /\A\p{Lu}/
    text[text_spans[j-1][2]...text_spans[j][1]] !~ SENTENCE_BREAK_RX
  end

  # Keep punctuation inside each run of consecutive words, space-join the gaps,
  # so we get "U.S.S. Enterprise-D" and "Dr. Crusher" instead of word soup
  def rebuild(name, name_spans, used)
    used.slice_when{|a, b| b != a + 1}.map{|run|
      from = name_spans[run.first][1]
      to = name_spans[run.last][2]
      to += 1 if name[to] == "."
      name[from...to]
    }.join(" ")
  end

  # A lone word which is also one of the game's creature types is much more likely
  # to be that type - "create a 4/4 red Dragon creature token" on Dragon Cultist
  def noise?(short)
    return false if short.include?(" ")
    FUNCTION_WORDS.include?(short) or creature_types.include?(short)
  end

  def creature_types
    @creature_types ||= begin
      result = Set[]
      each_printing do |card|
        next unless (card["types"] || []).include?("Creature")
        result += card["subtypes"] if card["subtypes"]
      end
      result
    end
  end

  def words(str)
    str.scan(WORD_RX)
  end

  # [word, start, end], so we can rebuild names with their original punctuation
  def word_spans(str)
    str.to_enum(:scan, WORD_RX).map{
      [Regexp.last_match[0], Regexp.last_match.begin(0), Regexp.last_match.end(0)]
    }
  end

  # "Agatha's power" refers to Agatha
  def same_word?(name_word, text_word)
    name_word == text_word or text_word.sub(/['’]s\z/, "") == name_word
  end
end
