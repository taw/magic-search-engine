class PatchSetCodes < Patch
  def call
    each_set do |set|
      set["code"] = set["official_code"]&.downcase

      # magiccards.info uses different codes for some sets, expose them as alternative_code
      alternative_code = mci_codes[set["code"]]
      if alternative_code and alternative_code != set["code"]
        set["alternative_code"] = alternative_code
      end

      set.delete("official_code")
    end

    duplicated_codes = @sets
      .group_by{|s| s["code"]}
      .transform_values(&:size)
      .select{|_,v| v > 1}
    unless duplicated_codes.empty?
      raise "There are duplicated set codes: #{duplicated_codes.keys}"
    end

    each_printing do |card|
      card["set_code"] = card["set"]["code"]
    end
  end

  def mci_codes
    @mci_codes ||= begin
      mci_codes_path = Indexer::ROOT + "mci_set_codes.txt"
      mci_codes_path.readlines.map(&:chomp).map{|x| x.split}.to_h
    end
  end
end
