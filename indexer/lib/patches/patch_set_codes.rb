class PatchSetCodes < Patch
  def call
    each_set do |set|
      set["code"] = set["official_code"]&.downcase

      # magiccards.info and MTG Arena use different codes for some sets,
      # expose them as alternative_code
      alternative_code = mci_codes[set["code"]] || arena_codes[set["code"]]
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

    check_alternative_codes!

    each_printing do |card|
      card["set_code"] = card["set"]["code"]
    end
  end

  # There's only one alternative_code slot per set, and resolve_editions prefers
  # real codes over alternative ones, so any of these would silently lose a mapping.
  # Both files contain entries for sets we no longer have, so only check what got applied.
  def check_alternative_codes!
    codes = @sets.map{|s| s["code"]}
    both = codes.select{|c| mci_codes[c] and arena_codes[c]}
    unless both.empty?
      raise "There are sets with both mci and arena codes: #{both}"
    end

    alternative_codes = @sets.filter_map{|s| s["alternative_code"]}
    shadowed = alternative_codes & codes
    unless shadowed.empty?
      raise "There are alternative set codes which are also real set codes: #{shadowed}"
    end

    duplicated = alternative_codes.tally.select{|_,v| v > 1}
    unless duplicated.empty?
      raise "There are duplicated alternative set codes: #{duplicated.keys}"
    end
  end

  def mci_codes
    @mci_codes ||= read_codes("mci_set_codes.txt")
  end

  # Arena renames a handful of sets. It also lumps every Alchemy set into
  # Y22..Y26, and that many-to-one mapping can't be expressed here.
  def arena_codes
    @arena_codes ||= read_codes("arena_set_codes.txt")
  end

  def read_codes(file_name)
    (Indexer::ROOT + file_name).readlines.map(&:chomp).map{|x| x.split}.to_h
  end
end
