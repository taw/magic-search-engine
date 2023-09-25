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
    tafr = add_tokens_set(afr)
    dungeons = afr["tokens"].select{|t| t["types"].include?("Dungeon") }

    dungeons.each do |token|
      token["set"] = tafr
      token["rarity"] = "common"
      token["layout"] = "dungeon"
      add_token token
    end
  end

  def add_tclb
    clb = @sets.find{|s| s["official_code"] == "CLB" }
    tclb = add_tokens_set(clb)
    dungeons = clb["tokens"].select{|t| t["types"].include?("Dungeon")}
    initiative = clb["tokens"].select{|t| t["name"] =~ /The Initiative/ and !t["types"].include?("Dungeon")}

    # We need to un-DFC it
    dungeons.each do |token|
      token["set"] = tclb
      token["rarity"] = "common"
      token["layout"] = "dungeon"
      token["name"] = token.delete("faceName")
      token["number"] += "b"
      token.delete("artist")
      add_token token
    end

    initiative.each do |token|
      token["set"] = tclb
      token["rarity"] = "common"
      token["layout"] = "token" # not really
      token["name"] = token.delete("faceName")
      token["number"] += "a"
      token["types"] = []
      token.delete("artist")
      add_token token
    end
  end

  def add_tltr
    ltr = @sets.find{|s| s["official_code"] == "LTR" }
    tltr = add_tokens_set(ltr)
    ring = ltr["tokens"].select{|t| t["name"] =~ /Ring/}

    ring.each do |token|
      token["set"] = tltr
      token["rarity"] = "common"
      token["layout"] = "token" # not really
      token["name"] = token.delete("faceName")
      token["types"] = []
      if token["name"] == "The Ring"
        token["number"] += "a"
      else
        token["number"] += "b"
      end
      token.delete("artist")
      add_token token
    end
  end

  def add_token(token)
    token["availability"].delete("paper")
    token["token"] = true
    (@cards[token["name"]] ||= []) << token
  end

  def add_tokens_set(base_set)
    code = "T" + base_set["official_code"]
    name = "#{base_set["name"]} Tokens"
    token_set = {
      "official_code" => code, # nothing official about it
      "name" => name,
      "type" => "token",
      "meta" => base_set["meta"],
      "releaseDate" => base_set["releaseDate"],
    }
    @sets << token_set
    token_set
  end
end
