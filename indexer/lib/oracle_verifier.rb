class OracleVerifier
  def initialize(printings, field_name)
    @printings = printings
    @field_name = field_name
  end

  def canonical
    # All versions are same, no reason to dig deeper
    if variants.size == 1
      variants.keys.first
    else
      # Something failed
      reconcile
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

  def reconcile
    # There are multiple versions, we need to figure out which works

    if @field_name == "rulings"
      # That's low value fail, would be nice if they fixed it, but whatever
      # FIXME: actually not really, "his or her" takes false priority over "their"
      return @variants.keys.max_by{|v| v.to_s.size}
    elsif @field_name == "subtypes"
      if card_name == "Aesthir Glider"
        canonical_variant_source = "dom"
      end
    else
      # Transition
      rx = /his or her|him or her|he or she|mana pool|target creature or player/i
      if @variants.keys.any?{|x| x =~ rx }
        good = @variants.keys.select{|x| x !~ rx}
        return good[0] if good.size == 1
      elsif @variants.keys.any?{|x| x =~ /this spell/i } and @variants.keys.any?{|x| x !~ /this spell/i }
        good = @variants.keys.select{|x| x =~ /this spell/i }
        return good[0] if good.size == 1
      elsif ["Land Tax", "Skyshroud Claim", "Vigor", "Fertilid", "Daggerback Basilisk", "Unflinching Courage", "Plated Crusher"].include?(card_name)
        canonical_variant_source = "bbd"
      else
        # first line: never updated (also: UGL,UNH,UST,S00)
        # second line: not updated yet
        known_outdated = %W[
          ced cedi bok st2k v17 cp2
          rep mbp rqs arena itp at mprp wotc thgt dpa jr cp gtw ptc sus jr fnmp pro mgdc mlp
        ]
        maybe_good_variants = {}
        @variants.each do |variant, sets|
          sets -= known_outdated
          next if sets.empty?
          maybe_good_variants[variant] = sets
        end
        if maybe_good_variants.size == 1
          return maybe_good_variants.keys[0]
        else
          warn [card_name, maybe_good_variants]
          # binding.pry
        end
      end
    end

    if canonical_variant_source
      @variants.to_a.find{|variant,sets| sets.include?(canonical_variant_source)}.first
    end
  end
end
