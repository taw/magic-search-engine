class SetCodeTranslator
  def initialize(data)
    @translator = {}
    # Some fixes to the mapper
    @translator["CM1"] = "cm1"
    @translator["CMA"] = "cma"
    @translator["pGTW"] = "gtw"
    @translator["pWPN"] = "wpn"
    # Silly to change retroactively
    @translator["MPS"] = "mps"
    @translator["MPS_AKH"] = "mps_akh"
    data.each_set do |set_code, set_data|
      @translator[set_code] ||= set_data["magicCardsInfoCode"] || set_data["code"].downcase
    end

    duplicated_codes = @translator
      .values
      .group_by(&:itself)
      .transform_values(&:size)
      .select{|_,v| v > 1}
    unless duplicated_codes.empty?
      raise "There are duplicated set codes: #{duplicated_codes.keys}"
    end
  end

  def [](set_code)
    @translator[set_code] or raise "Unknown set #{set_code}"
  end
end
