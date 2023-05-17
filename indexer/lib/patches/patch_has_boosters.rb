class PatchHasBoosters < Patch
  # Maybe there's a way to do this automatically?
  def included_in_other_boosters
    %W[
      brr
      exp
      fmb1
      mp2
      mps
      plist
      sis
      slx
      sta
      sunf
      tsb
    ]
  end

  def boosters_root
    Indexer::ROOT + "boosters"
  end

  def booster_files_for(set_code)
    (Indexer::ROOT + "boosters").glob("#{set_code}*.yaml").map{|s| s.basename(".yaml").to_s.delete("_")}
  end

  def call
    each_set do |set|
      set["has_boosters"] = false

      set_code = set["code"]
      set_name = set["name"]
      set["in_other_boosters"] = !!included_in_other_boosters.include?(set["code"])

      booster_files = booster_files_for(set_code)

      next if booster_files.empty?

      set["has_boosters"] = true
    end
  end
end
