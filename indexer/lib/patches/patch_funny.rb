class PatchFunny < Patch
  def call
    errata_sets = @sets.select{|set| set["type"] == "errata"}.map{|set| set["code"].downcase}
    funny_sets = %W[uh ug uqc hho arena rep ust]
    each_card do |name, printings|
      funny = printings.all?{|card| funny_sets.include?(card["set_code"]) || errata_sets.include?(card["set_code"]) }

      if funny
        printings.each do |printing|
          printing["funny"] = true
        end
      end
    end
  end
end
