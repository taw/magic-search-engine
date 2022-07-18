class PatchArtistNames < Patch
  def valid_no_art
    @valid_no_art ||= [
      ["Look at Me, I'm R&D", "unh", "17"],
      ["Look at Me, I'm R&D", "und", "9"],
      ["Plains", "sld", "254"],
      ["Island", "sld", "255"],
      ["Swamp", "sld", "256"],
      ["Mountain", "sld", "257"],
      ["Forest", "sld", "258"],
      ["Terramorphic Expanse", "sld", "585"],
      ["Tomb of Annihilation", "tafr", "22"],
      ["Dungeon of the Mad Mage", "tafr", "20"],
      ["Lost Mine of Phandelver", "tafr", "21"],
      ["Undercity", "tclb", "20"],
    ]
  end

  def call
    # Prevent slug conflicts
    each_printing do |card|
      unless card["artist"]
        unless valid_no_art.include?([card["name"], card["set_code"], card["number"]])
          warn "No artist for #{card["name"]} #{card["set_code"]} #{card["number"]}"
        end
        card["artist"] = "unknown"
      end
    end
  end
end
