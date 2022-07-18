# We normally don't do tokens, but there's tiny number of exceptions:
# * AFR dungeons
# * CLB dungeons
class PatchTokens < Patch
  def call
    add_tafr
    add_tclb
  end

  def add_tafr
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

  def add_tclb
    clb = @sets.find{|s| s["official_code"] == "CLB" }
    dungeons = clb["tokens"].select{|t| t["type"] =~ /Dungeon/}

    tclb = {
      "official_code" => "TCLB", # nothing official about it
      "name" => "Commander Legends: Battle for Baldur's Gate Tokens",
      "type" => "token",
      "meta" => clb["meta"],
      "releaseDate" => clb["releaseDate"],
    }
    @sets << tclb
    # We need to un-DFC it
    dungeons.each do |dungeon|
      dungeon["set"] = tclb
      dungeon["rarity"] = "common"
      dungeon["layout"] = "dungeon"
      dungeon["availability"].delete("paper")
      dungeon["name"] = dungeon.delete("faceName")
      dungeon.delete("artist")
      (@cards[dungeon["name"]] ||= []) << dungeon
    end
  end
end
