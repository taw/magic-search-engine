# mtgjson v4 decided to make releaseDate per-set
# that leads to need for a lot of BS adjustments

# I trust unsourced mtg wiki claim here more
# since this is definitely wrong
# https://mtg.gamepedia.com/Duel_Decks:_Mirrodin_Pure_vs._New_Phyrexia
class PatchReleaseDates < Patch
  def call
    each_set do |set|
      case set["code"]
      when "td2"
        set["releaseDate"] = "2013-01-11"
      # Some random tweaks
      when "c18"
        set["releaseDate"] = "2018-08-10"
      when "ddt"
        set["releaseDate"] = "2017-11-10"
      when "ppro"
        set["releaseDate"] = "2018-01-01"
      when "p02"
        set["releaseDate"] = "1998-06-24"
      when "pz2"
        set["releaseDate"] = "2018-08-10"
      when "prm"
        set["releaseDate"] = "2018-08-10"
      when "c20"
        set["releaseDate"] = "2020-04-17"
      end
    end
  end
end
