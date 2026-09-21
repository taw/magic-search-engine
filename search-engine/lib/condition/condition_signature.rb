class ConditionSignature < ConditionSimple
  def initialize(signature)
    @signature = signature
    @any = (signature == "*")
    @signature_rx = Regexp.new("\\b(?:" + Regexp.escape(signature.normalize_accents) + ")\\b", Regexp::IGNORECASE)
  end

  def match?(card)
    return false unless card.signature
    return true if @any
    card.signature.normalize_accents =~ @signature_rx
  end

  def to_s
    "sig:#{maybe_quote(@signature)}"
  end

  def explain(negated: false)
    if @any
      negated ? "the card has no signature" : "the card has a signature"
    else
      verb = negated ? "doesn't include" : "includes"
      %[the signature #{verb} "#{@signature}"]
    end
  end
end
