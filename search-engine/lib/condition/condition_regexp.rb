# This needs timeout check, as it can be exponentially slow
class ConditionRegexp < ConditionSimple
  def initialize(regexp)
    @regexp = regexp
  end

  def match?(card)
    raise "SubclassResponsibility"
  end

  # No general paraphrase for a regex, so just name the field and quote the pattern -
  # same fallback Scryfall itself uses ("... where the text matches the regex /dragon/").
  def explain
    "#{field_description} matches the regex /#{@regexp.source}/"
  end

  private

  def field_description
    "the text"
  end
end
