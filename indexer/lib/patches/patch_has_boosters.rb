class PatchHasBoosters < Patch
  def included_in_other_boosters
    %W[
      brr
      exp
      fmb1
      mp2
      mps
      plist
      sis
      sta
      sunf
      tsb
      slx
    ]
  end

  def boosters_root
    Indexer::ROOT + "boosters"
  end

  def booster_files_for(set_code)
    (Indexer::ROOT + "boosters").glob("#{set_code}*.yaml").map{|s| s.basename(".yaml").to_s.gsub("_", "")}
  end

  def call
    each_set do |set|
      # mtgjson data, might be stale, so we need to override it
      set["has_boosters"] = false

      set_code = set["code"]
      set_name = set["name"]
      set["in_other_boosters"] = !!included_in_other_boosters.include?(set["code"])

      booster_files = booster_files_for(set_code)

      next if booster_files.empty?

      set["has_boosters"] = true
      set["booster_variants"] = {}

      booster_files.each do |booster_code|
        variant = booster_code.split("-", 2)[1] || "default"

        set["booster_variants"][variant] = case booster_code
        when set_code
          nil
        when "#{set_code}-arena"
          "#{set_name} Arena Booster"
        when "#{set_code}-set"
          "#{set_name} Set Booster"
        when "#{set_code}-collector"
          "#{set_name} Collector Booster"
        when "sir-arena-1"
           "#{set_name} Arena Booster: Creature Type Terror"
        when "sir-arena-2"
           "#{set_name} Arena Booster: Fatal Flashback"
        when "sir-arena-3"
           "#{set_name} Arena Booster: Morbid And Macabre"
        when "sir-arena-4"
           "#{set_name} Arena Booster: Abominable All Stars"
        when "ala-premium"
           "Alara Premium Foil Booster"
        else
          warn "Unknown booster type: #{booster_code}"
          "#{set_name} #{variant.capitalize} Booster"
        end
      end
    end
  end
end
