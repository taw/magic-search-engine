class PatchBlocks < Patch
  MagicBlocks = [
    [ "ia", "ice", "Ice Age", "ia", "ai", "cs"],
    [ "mr", "mir", "Mirage", "mr", "vi", "wl"],
    [ "tp", "tmp", "Tempest", "tp", "sh", "ex"],
    [ "us", "usg", "Urza's Saga", "us", "ul", "ud"],
    [ "mm", "mmq", "Mercadian Masques", "mm", "ne", "pr"],
    [ "in", "inv", "Invasion", "in", "ps", "ap"],
    [ "od", "ody", "Odyssey", "od", "tr", "ju"],
    [ "on", "ons", "Onslaught", "on", "le", "sc"],
    [ "mi", "mrd", "Mirrodin", "mi", "ds", "5dn"],
    ["chk",  nil,  "Champions of Kamigawa", "chk", "bok", "sok"],
    ["rav",  nil,  "Ravnica", "rav", "gp", "di"],
    [ "ts", "tsp", "Time Spiral", "ts", "tsts", "pc", "fut"],
    # Should Shadowmoor be its own block?
    [ "lw", "lrw", "Lorwyn", "lw", "mt", "shm", "eve"],
    ["ala",  nil,  "Shards of Alara", "ala", "cfx", "arb"],
    ["zen",  nil,  "Zendikar", "zen", "wwk", "roe"],
    ["som",  nil,  "Scars of Mirrodin", "som", "mbs", "nph"],
    ["isd",  nil,  "Innistrad", "isd", "dka", "avr"],
    ["rtr",  nil,  "Return to Ravnica", "rtr", "gtc", "dgm"],
    ["ths",  nil,  "Theros", "ths", "bng", "jou"],
    ["ktk",  nil,  "Khans of Tarkir", "ktk", "frf", "dtk"],
    ["bfz",  nil,  "Battle for Zendikar", "bfz", "ogw"],
    ["soi",  nil,  "Shadows over Innistrad", "soi", "emn"],
    ["kld",  nil,  "Kaladesh", "kld", "aer"],
    ["akh",  nil,  "Amonkhet", "akh", "hou"],
    ["xln",  nil,  "Ixalan", "xln", "rix"],
    ["dom",  nil,  "Dominaria", "dom"],
    [ "un",  nil,  "Unsets", "ug", "uh", "ust"],
  ]

  def block_by_set_code(set_code)
    MagicBlocks.find do |block_info|
      block_info[3..-1].include?(set_code)
    end
  end

  def call
    each_set do |set|
      code, code2, name = block_by_set_code(set["code"])
      set.merge!({
        "block_code" => code,
        "gatherer_block_code" => code2,
        "block_name" => name,
      }.compact)
    end
  end
end
