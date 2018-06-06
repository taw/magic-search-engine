class SetPriorityBasedReconciliation
  def initialize(printings, field_name)
    @printings = printings
    @field_name = field_name
  end

  def reconcile
    # All versions are same, no reason to dig deeper
    return if variants.size == 1

    # Something failed
    success, canonical = run_reconciliation
    if success
      @printings.each do |printing|
        printing[@field_name] = canonical
      end
    end
  end

  private

  def card_name
    @card_name ||= @printings[0]["name"]
  end

  def variants
    unless @variants
      @variants = {}
      @printings.each do |printing|
        set_code = printing["set_code"]
        variant = printing[@field_name]
        (@variants[variant] ||= []) << set_code
      end
    end
    @variants
  end

  def set_priorities
    {
      # These are mostly various promos which are not on Gatherer
      -1 => %W[
        ced cedi bok st2k v17 cp1 cp2 cp3
        rep mbp rqs arena itp at mprp wotc thgt dpa jr cp gtw ptc sus jr fnmp pro mgdc mlp
        dm cstd dcilm wpn mgbc sum 15ann gpx wmcq
      ],
      # default priority level, everything not explicitly listed goes here
      0 => [],
      # whichever sets got updated since last full mtgjson update
      1  => %W[dom],
      2  => %W[bbd],
    }
  end

  # TODO: give custom sets max priority
  def set_priority(set_code)
    priority, = set_priorities.find{|k,v| v.include?(set_code) }
    priority || 0
  end

  # There are multiple versions, we need to figure out which works
  def run_reconciliation
    variants_by_priority = {}
    variants.each do |variant, set_codes|
      priority = set_codes.map{|set_code| set_priority(set_code)}.max
      (variants_by_priority[priority] ||= []) << variant
    end

    priority_variants = variants_by_priority[variants_by_priority.keys.max]

    return [true, priority_variants[0]] if priority_variants.size == 1

    # This should be more meaningful warning
    warn "Can't reconcile #{card_name}"
    return [false, nil]
  end
end
