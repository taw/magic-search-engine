class PatchSubsets < Patch
  def call
    subset_map = {}
    each_printing do |card|
      set_code = card["set"]["code"]
      next unless card["subsets"]
      card["subsets"].each do |subset|
        subset_map[set_code] ||= Set[]
        subset_map[set_code] << subset
      end
    end

    each_set do |set|
      set_code = set["code"]
      next unless subset_map[set_code]
      set["subsets"] = subset_map[set_code].sort
    end
  end
end
