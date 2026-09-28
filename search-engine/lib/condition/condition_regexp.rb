# This needs timeout check, as it can be exponentially slow
class ConditionRegexp < ConditionSimple
  # raw_source is the pattern exactly as typed, before the tokenizer expands the
  # \sm/\spt/\smr/... shortcuts into their real (unreadable) regex. It's only used
  # for #explain - #to_s still reconstructs from @regexp, since that's what has to
  # round-trip through the parser. Left out of state_ivars so it never affects
  # equality/hash - two conditions that match the same thing are still the same
  # condition no matter how the query that built them chose to spell it.
  def initialize(regexp, raw_source = nil)
    @regexp = regexp
    @raw_source = raw_source
  end

  def match?(card)
    raise "SubclassResponsibility"
  end

  def state_ivars
    super - [:@raw_source]
  end

  # No general paraphrase for a regex, so just name the field and quote the pattern -
  # same fallback Scryfall itself uses ("... where the text matches the regex /dragon/").
  # Backtick-wrapped so the frontend renders it monospace, like inline code.
  def explain(negated: false)
    verb = negated ? "doesn't match" : "matches"
    "#{field_description} #{verb} the regex `/#{@raw_source || @regexp.source}/`"
  end

  private

  def field_description
    "the text"
  end
end
