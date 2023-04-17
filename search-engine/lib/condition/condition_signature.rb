class ConditionSignature < ConditionSimple
  def initialize(signature)
    @signature = signature
    @signature_rx = Regexp.new("\\b(?:" + Regexp.escape(signature.normalize_accents) + ")\\b", Regexp::IGNORECASE)
  end

  def match?(card)
    return false unless card.signature
    return true if @signature == "*"
    card.signature.normalize_accents =~ @signature_rx
  end

  def to_s
    "sig:#{maybe_quote(@signature)}"
  end
end
