# Fixing printing dates of promo cards
# If we treat prerelease promos as released at prerelease
# but actualy cards as released at release
# this messes up with is:reprint etc.
#
# It's not pretty, but better than nothing
class PatchFixPromoPrintDates < Patch
  def call
    @cards.each do |name, printings|
      # Prerelease
      ptc_printing = printings.find{|c| c["set_code"] == "ptc" }
      # Release
      mlp_printing = printings.find{|c| c["set_code"] == "mlp" }
      # Gameday
      mgdc_printing = printings.find{|c| c["set_code"] == "mgdc" }
      # Media inserts
      mbp_printing = printings.find{|c| c["set_code"] == "mbp" }

      real_printings = printings.select{|c| !["ptc", "mlp", "mgdc", "mbp"].include?(c["set_code"]) }
      guess_date = real_printings.map{|c| c["release_date"] || @sets[c["set_code"]]["release_date"] }.min

      if ptc_printing and not ptc_printing["release_date"]
        raise "No guessable date for #{name}" unless guess_date
        guess_ptc_date = (Date.parse(guess_date) - 6).to_s
        ptc_printing["release_date"] = guess_ptc_date
      end
      if mlp_printing and not mlp_printing["release_date"]
        raise "No guessable date for #{name}" unless guess_date
        mlp_printing["release_date"] = guess_date
      end
      if mgdc_printing and not mgdc_printing["release_date"]
        raise "No guessable date for #{name}" unless guess_date
        mgdc_printing["release_date"] = guess_date
      end
      if mbp_printing and not mbp_printing["release_date"]
        raise "No guessable date for #{name}" unless guess_date
        mbp_printing["release_date"] = guess_date
      end
    end
  end
end
