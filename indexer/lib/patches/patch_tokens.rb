# We normally don't do tokens, but there's tiny number of exceptions:
# * AFR dungeons
class PatchTokens < Patch
  def call
    afr = @sets.find{|s| s["official_code"] == "AFR" }
    dungeons = afr["tokens"].select{|t| t["type"] == "Dungeon"}

    tafr = {
      "official_code" => "TAFR", # nothing official about it
      "name" => "Adventures in the Forgotten Realms Tokens",
      "type" => "token",
      "meta" => afr["meta"],
      "releaseDate" => afr["releaseDate"],
    }

    @sets << tafr
    dungeons.each do |dungeon|
      dungeon["set"] = tafr
      dungeon["rarity"] = "common"
      dungeon["layout"] = "dungeon"
      dungeon["availability"].delete("paper")
      (@cards[dungeon["name"]] ||= []) << dungeon
    end
  end
end
