# mtgjson mostly uses gatherer codes as primary
# we mostly use mci codes
# with some exceptions in both cases
class PatchSetCodes < Patch
  def call
    # Forced lower case for all codes
    each_set do |set|
      set["code"] = set["code"]&.downcase
      set["gatherer_code"] = set["gatherer_code"]&.downcase
      set["official_code"] = set["official_code"]&.downcase
    end

    each_set do |set|
      set["code"] ||= set["official_code"]
      case set["official_code"]
      when "pgtw"
        set["code"] = "gtw"
      when "pwpn"
        set["code"] = "wpn"
      when "cm1", "cma", "mps", "mps_akh", "cp1", "cp2", "cp3"
        set["code"] = set["official_code"]
      end
      # Only include it if different from both official and MCI codes
      set.delete("gatherer_code") if set["gatherer_code"]&.downcase == set["code"]
      # Delete ones conflicting with MCI codes for different sets
      set.delete("gatherer_code") if %W[al st le mi].include?(set["gatherer_code"])
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
