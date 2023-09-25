# We normally don't do tokens, but there's tiny number of exceptions:
# * AFR dungeons
# * CLB dungeons
class PatchTokens < Patch
  def call
    add_tafr
    add_tclb
    add_tltr
  end

  def add_tafr
    afr = @sets.find{|s| s["official_code"] == "AFR" }
    dungeons = afr["tokens"].select{|t| t["types"].include?("Dungeon") }

    tafr = {
      "official_code" => "TAFR", # nothing official about it
      "name" => "Adventures in the Forgotten Realms Tokens",
      "type" => "token",
      "meta" => afr["meta"],
      "releaseDate" => afr["releaseDate"],
    }

    @sets << tafr
    dungeons.each do |token|
      token["set"] = tafr
      token["rarity"] = "common"
      token["layout"] = "dungeon"
      token["availability"].delete("paper")
      token["token"] = true
      add_token token
    end
  end

  def add_tclb
    clb = @sets.find{|s| s["official_code"] == "CLB" }
    dungeons = clb["tokens"].select{|t| t["types"].include?("Dungeon")}
    initiative = clb["tokens"].select{|t| t["name"] =~ /The Initiative/ and !t["types"].include?("Dungeon")}

    tclb = {
      "official_code" => "TCLB", # nothing official about it
      "name" => "Commander Legends: Battle for Baldur's Gate Tokens",
      "type" => "token",
      "meta" => clb["meta"],
      "releaseDate" => clb["releaseDate"],
    }
    @sets << tclb
    # We need to un-DFC it
    dungeons.each do |token|
      token["set"] = tclb
      token["rarity"] = "common"
      token["layout"] = "dungeon"
      token["availability"].delete("paper")
      token["name"] = token.delete("faceName")
      token["number"] += "b"
      token["token"] = true
      token.delete("artist")
      add_token token
    end

    initiative.each do |token|
      token["set"] = tclb
      token["rarity"] = "common"
      token["layout"] = "token" # not really
      token["availability"].delete("paper")
      token["name"] = token.delete("faceName")
      token["number"] += "a"
      token["token"] = true
      token["types"] = []
      token.delete("artist")
      add_token token
    end
  end

  def add_tltr
    ltr = @sets.find{|s| s["official_code"] == "LTR" }
    ring = ltr["tokens"].select{|t| t["name"] =~ /Ring/}
    tltr = {
      "official_code" => "TLTR", # nothing official about it
      "name" => "The Lord of the Rings: Tales of Middle-earth Tokens",
      "type" => "token",
      "meta" => ltr["meta"],
      "releaseDate" => ltr["releaseDate"],
    }
    @sets << tltr

    ring.each do |token|
      token["set"] = tltr
      token["rarity"] = "common"
      token["layout"] = "token" # not really
      token["availability"].delete("paper")
      token["name"] = token.delete("faceName")
      token["types"] = []
      if token["name"] == "The Ring"
        token["number"] += "a"
      else
        token["number"] += "b"
      end
      token["token"] = true
      token.delete("artist")
      add_token token
    end
  end

  def add_token(token)
    (@cards[token["name"]] ||= []) << token
  end
end
