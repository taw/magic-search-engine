# This is a convoluted process due to v3 to v4 migration
# We'll be able to clean it up (and just load from file) at some point

class PatchSetCodes < Patch
  def call
    # Forced lower case for all codes
    each_set do |set|
      set["mci_code"] = set["mci_code"]&.downcase
      set["official_code"] = set["official_code"]&.downcase
    end

    each_set do |set|
      if %W[cm1 cma mps mp2 cp1 cp2 cp3 pgtw pwpn].include?(set["official_code"])
        set.delete("mci_code")
      end

      set["code"] = set["official_code"] || set["mci_code"]

      # v4 killed mci codes, so reapply them
      mci_code = mci_codes[set["code"]]
      if mci_code
        if set["mci_code"] and set["mci_code"] != mci_code
          warn "Mismatching MCI code for #{set["code"]}: #{set["mci_code"].inspect} != #{mci_code.inspect}"
        end
        set["mci_code"] = mci_code
      end

      set["alternative_code"] = set.delete("mci_code")

      # Delete if redundant
      set.delete("alternative_code") if set["alternative_code"] == set["code"]

      # Delete ones conflicting with official or alternative codes for different sets
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
