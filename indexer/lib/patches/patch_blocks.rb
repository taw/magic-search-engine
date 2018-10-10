class PatchBlocks < Patch
  MagicBlocks = [
    ["ice", "ia", "Ice Age", "ice", "all", "csp"],
    ["mir", "mr", "Mirage", "mir", "vis", "wth"],
    ["tmp", "tp", "Tempest", "tmp", "sth", "exo"],
    ["usg", "us", "Urza's Saga", "usg", "ulg", "uds"],
    ["mmq", "mm", "Mercadian Masques", "mmq", "nms", "pcy"],
    ["inv", "in", "Invasion", "inv", "pls", "apc"],
    ["ody", "od", "Odyssey", "ody", "tor", "jud"],
    ["ons", "on", "Onslaught", "ons", "lgn", "scg"],
    ["mrd", "mi", "Mirrodin", "mrd", "dst", "5dn"],
    ["chk",  nil, "Champions of Kamigawa", "chk", "bok", "sok"],
    ["rav",  nil, "Ravnica", "rav", "gpt", "dis"],
    ["tsp", "ts", "Time Spiral", "tsp", "tsb", "plc", "fut"],
    # Should Shadowmoor be its own block?
    ["lrw", "lw", "Lorwyn", "lrw", "mor", "shm", "eve"],
    ["ala",  nil, "Shards of Alara", "ala", "con", "arb"],
    ["zen",  nil, "Zendikar", "zen", "wwk", "roe"],
    ["som",  nil, "Scars of Mirrodin", "som", "mbs", "nph"],
    ["isd",  nil, "Innistrad", "isd", "dka", "avr"],
    ["rtr",  nil, "Return to Ravnica", "rtr", "gtc", "dgm"],
    ["ths",  nil, "Theros", "ths", "bng", "jou"],
    ["ktk",  nil, "Khans of Tarkir", "ktk", "frf", "dtk"],
    ["bfz",  nil, "Battle for Zendikar", "bfz", "ogw"],
    ["soi",  nil, "Shadows over Innistrad", "soi", "emn"],
    ["kld",  nil, "Kaladesh", "kld", "aer"],
    ["akh",  nil, "Amonkhet", "akh", "hou"],
    ["xln",  nil, "Ixalan", "xln", "rix"],
    ["dom",  nil, "Dominaria", "dom"],
    [ "un",  nil, "Unsets", "ugl", "unh", "ust"],
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
        "alternative_block_code" => code2,
        "block_name" => name,
      }.compact)
    end
  end
end
