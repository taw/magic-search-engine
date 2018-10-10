# We're in process of switching from MCI to official codes as primary

class PatchSetCodes < Patch
  def call
    # Forced lower case for all codes
    each_set do |set|
      set["mci_code"] = set["mci_code"]&.downcase
      set["gatherer_code"] = set["gatherer_code"]&.downcase
      set["official_code"] = set["official_code"]&.downcase
    end

    each_set do |set|
      if set["type"] == "core" or set["type"] == "expansion" or set["official_code"] == "chr"
        set["code"] = set["official_code"]
        set["alternative_code"] = set["mci_code"]
        if set["code"] != set["alternative_code"]
          p [set["alternative_code"], set["code"]]
        end
      else
        set["code"] = set["mci_code"] || set["official_code"]
        set["alternative_code"] = set["official_code"]
      end

      case set["official_code"]
      when "pgtw"
        set["code"] = "gtw"
      when "pwpn"
        set["code"] = "wpn"
      when "cm1", "cma", "mps", "mps_akh", "cp1", "cp2", "cp3"
        set["code"] = set["official_code"]
      end

      # Delete if redundant
      set.delete("alternative_code") if set["alternative_code"] == set["code"]
      set.delete("gatherer_code") if set["gatherer_code"] == set["code"]
      set.delete("gatherer_code") if set["gatherer_code"] == set["alternative_code"]

      # Delete ones conflicting with official or alternative codes for different sets
      set.delete("gatherer_code") if %W[al st le mi].include?(set["gatherer_code"])

      set.delete("official_code")
      set.delete("mci_code")
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
end
