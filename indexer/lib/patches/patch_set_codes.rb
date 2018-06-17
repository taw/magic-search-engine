# mtgjson mostly uses gatherer codes as primary
# we mostly use mci codes
# with some exceptions in both cases
class PatchSetCodes < Patch
  def call
    each_set do |set|
      set["code"] ||= set["official_code"].downcase
      case set["official_code"]
      when "pGTW"
        set["code"] = "gtw"
      when "pWPN"
        set["code"] = "wpn"
      when "CM1", "CMA", "MPS", "MPS_AKH", "CP1", "CP2", "CP3"
        set["code"] = set["official_code"].downcase
      end
      # Only include it if different from both official and MCI codes
      set.delete("gatherer_code") if set["gatherer_code"]&.downcase == set["code"]
      # Delete ones conflicting with MCI codes for different sets
      set.delete("gatherer_code") if %W[AL ST LE MI].include?(set["gatherer_code"])
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
