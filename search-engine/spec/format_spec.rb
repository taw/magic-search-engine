describe "Formats" do
  include_context "db"

  ## General queries

  it "formats" do
    assert_search_equal "f:standard", "legal:standard"
    assert_search_results "f:extended" # Does not exist according to mtgjson
    assert_search_equal "f:standard",
      %Q[(e:kld or e:aer or e:akh or e:w17 or e:hou or e:xln) -"Smuggler's Copter" -"Felidar Guardian" -"Aetherworks Marvel"]
    assert_search_equal 'f:"ravnica block"', "e:rav or e:gp or e:di"
    assert_search_equal 'f:"ravnica block"', 'legal:"ravnica block"'
    assert_search_equal 'f:"ravnica block"', 'b:ravnica'
    assert_search_differ 'f:"mirrodin block" t:land', 'b:"mirrodin" t:land'
  end


  it "ban_events" do
    FormatInnistradBlock.new.ban_events.should eq({
       Date.parse("2012-04-01") => [
         {name: "Lingering Souls", old: "legal", new: "banned"},
         {name: "Intangible Virtue", old: "legal", new: "banned"},
       ],
    })
    FormatModern.new.ban_events.should eq({
      nil => [
       {:name=>"Ancestral Vision", :old=>"legal", :new=>"banned"},
       {:name=>"Ancient Den", :old=>"legal", :new=>"banned"},
       {:name=>"Bitterblossom", :old=>"legal", :new=>"banned"},
       {:name=>"Chrome Mox", :old=>"legal", :new=>"banned"},
       {:name=>"Dark Depths", :old=>"legal", :new=>"banned"},
       {:name=>"Dread Return", :old=>"legal", :new=>"banned"},
       {:name=>"Glimpse of Nature", :old=>"legal", :new=>"banned"},
       {:name=>"Great Furnace", :old=>"legal", :new=>"banned"},
       {:name=>"Hypergenesis", :old=>"legal", :new=>"banned"},
       {:name=>"Jace, the Mind Sculptor", :old=>"legal", :new=>"banned"},
       {:name=>"Mental Misstep", :old=>"legal", :new=>"banned"},
       {:name=>"Seat of the Synod", :old=>"legal", :new=>"banned"},
       {:name=>"Sensei's Divining Top", :old=>"legal", :new=>"banned"},
       {:name=>"Skullclamp", :old=>"legal", :new=>"banned"},
       {:name=>"Stoneforge Mystic", :old=>"legal", :new=>"banned"},
       {:name=>"Sword of the Meek", :old=>"legal", :new=>"banned"},
       {:name=>"Tree of Tales", :old=>"legal", :new=>"banned"},
       {:name=>"Umezawa's Jitte", :old=>"legal", :new=>"banned"},
       {:name=>"Vault of Whispers", :old=>"legal", :new=>"banned"},
       {:name=>"Golgari Grave-Troll", :old=>"legal", :new=>"banned"},
       {:name=>"Valakut, the Molten Pinnacle", :old=>"legal", :new=>"banned"},
      ],
      Date.parse("2011-10-01") => [
        {:name=>"Blazing Shoal", :old=>"legal", :new=>"banned"},
        {:name=>"Cloudpost", :old=>"legal", :new=>"banned"},
        {:name=>"Green Sun's Zenith", :old=>"legal", :new=>"banned"},
        {:name=>"Ponder", :old=>"legal", :new=>"banned"},
        {:name=>"Preordain", :old=>"legal", :new=>"banned"},
        {:name=>"Rite of Flame", :old=>"legal", :new=>"banned"},
      ],
      Date.parse("2012-01-01") => [
        {:name=>"Wild Nacatl", :old=>"legal", :new=>"banned"},
        {:name=>"Punishing Fire", :old=>"legal", :new=>"banned"},
      ],
      Date.parse("2012-10-01") => [
        {:name=>"Valakut, the Molten Pinnacle", :old=>"banned", :new=>"legal"},
      ],
      Date.parse("2013-02-01") => [
        {:name=>"Bloodbraid Elf", :old=>"legal", :new=>"banned"},
        {:name=>"Seething Song", :old=>"legal", :new=>"banned"},
      ],
      Date.parse("2013-05-03") => [
        {:name=>"Second Sunrise", :old=>"legal", :new=>"banned"},
      ],
      Date.parse("2014-02-07") => [
        {:name=>"Bitterblossom", :old=>"banned", :new=>"legal"},
        {:name=>"Deathrite Shaman", :old=>"legal", :new=>"banned"},
        {:name=>"Wild Nacatl", :old=>"banned", :new=>"legal"},
      ],
      Date.parse("2015-01-23") => [
       {:name=>"Dig Through Time", :old=>"legal", :new=>"banned"},
       {:name=>"Treasure Cruise", :old=>"legal", :new=>"banned"},
       {:name=>"Birthing Pod", :old=>"legal", :new=>"banned"},
       {:name=>"Golgari Grave-Troll", :old=>"banned", :new=>"legal"},
      ],
      Date.parse("2016-01-22") => [
        {:name=>"Summer Bloom", :old=>"legal", :new=>"banned"},
        {:name=>"Splinter Twin", :old=>"legal", :new=>"banned"},
      ],
      Date.parse("2016-04-08") => [
        {:name=>"Ancestral Vision", :old=>"banned", :new=>"legal"},
        {:name=>"Sword of the Meek", :old=>"banned", :new=>"legal"},
        {:name=>"Eye of Ugin", :old=>"legal", :new=>"banned"},
      ],
      Date.parse("2017-01-20")=>[
        {:name=>"Golgari Grave-Troll", :old=>"legal", :new=>"banned"},
        {:name=>"Gitaxian Probe", :old=>"legal", :new=>"banned"},
      ],
    })
  end

  ## Modern

  it "modern" do
    assert_block_composition "modern", "akh", ["8e", "mi", "ds", "5dn", "chk", "bok", "sok", "9e", "rav", "gp", "di", "cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt", "shm", "eve", "ala", "cfx", "arb", "m10", "zen", "wwk", "roe", "m11", "som", "mbs", "nph", "m12", "isd", "dka", "avr", "m13", "rtr", "gtc", "dgm", "m14", "ths", "bng", "jou", "m15", "ktk", "frf", "dtk", "ori", "bfz", "ogw", "soi", "emn", "kld", "aer", "akh"],
      "Ancient Den" => "banned",
      "Birthing Pod" => "banned",
      "Blazing Shoal" => "banned",
      "Bloodbraid Elf" => "banned",
      "Chrome Mox" => "banned",
      "Cloudpost" => "banned",
      "Dark Depths" => "banned",
      "Deathrite Shaman" => "banned",
      "Dig Through Time" => "banned",
      "Dread Return" => "banned",
      "Eye of Ugin" => "banned",
      "Gitaxian Probe" => "banned",
      "Glimpse of Nature" => "banned",
      "Golgari Grave-Troll" => "banned",
      "Great Furnace" => "banned",
      "Green Sun's Zenith" => "banned",
      "Hypergenesis" => "banned",
      "Jace, the Mind Sculptor" => "banned",
      "Mental Misstep" => "banned",
      "Ponder" => "banned",
      "Preordain" => "banned",
      "Punishing Fire" => "banned",
      "Rite of Flame" => "banned",
      "Seat of the Synod" => "banned",
      "Second Sunrise" => "banned",
      "Seething Song" => "banned",
      "Sensei's Divining Top" => "banned",
      "Skullclamp" => "banned",
      "Splinter Twin" => "banned",
      "Stoneforge Mystic" => "banned",
      "Summer Bloom" => "banned",
      "Treasure Cruise" => "banned",
      "Tree of Tales" => "banned",
      "Umezawa's Jitte" => "banned",
      "Vault of Whispers" => "banned"
    assert_legality "modern", "avr", "Rancor", nil
    assert_legality "modern", "m13", "Rancor", "legal"
    assert_legality "modern", "m12", "Wild Nacatl", "legal"
    assert_legality "modern", "m13", "Wild Nacatl", "banned"
    assert_legality "modern", "bng", "Wild Nacatl", "legal"
    assert_legality "modern", "m13", "Lightning Bolt", "legal"
  end

  ## Standard

  it "standard" do
    assert_block_composition "standard", "xln",  ["kld", "aer", "akh", "w17", "hou", "xln"],
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned",
      "Aetherworks Marvel" => "banned"
    assert_block_composition "standard", "hou",  ["bfz", "ogw", "soi", "w16", "emn", "kld", "aer", "akh", "w17", "hou"],
      "Emrakul, the Promised End" => "banned",
      "Reflector Mage" => "banned",
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned",
      "Aetherworks Marvel" => "banned"
    assert_block_composition "standard", "akh",  ["bfz", "ogw", "soi", "w16", "emn", "kld", "aer", "akh", "w17"],
      "Emrakul, the Promised End" => "banned",
      "Reflector Mage" => "banned",
      "Smuggler's Copter" => "banned",
      "Felidar Guardian" => "banned"
    assert_block_composition "standard", "aer",  ["bfz", "ogw", "soi", "w16", "emn", "kld", "aer"],
      "Emrakul, the Promised End" => "banned",
      "Reflector Mage" => "banned",
      "Smuggler's Copter" => "banned"
    assert_block_composition "standard", "kld",  ["bfz", "ogw", "soi", "w16", "emn", "kld"]
    assert_block_composition "standard", "emn",  ["dtk", "ori", "bfz", "ogw", "soi", "w16", "emn"]
    assert_block_composition "standard", "soi",  ["dtk", "ori", "bfz", "ogw", "soi", "w16"]
    assert_block_composition "standard", "ogw",  ["ktk", "frf", "dtk", "ori", "bfz", "ogw"]
    assert_block_composition "standard", "bfz",  ["ktk", "frf", "dtk", "ori", "bfz"]
    assert_block_composition "standard", "ori",  ["ths", "bng", "jou", "m15", "ktk", "frf", "dtk", "ori"]
    assert_block_composition "standard", "dtk",  ["ths", "bng", "jou", "m15", "ktk", "frf", "dtk"]
    assert_block_composition "standard", "frf",  ["ths", "bng", "jou", "m15", "ktk", "frf"]
    assert_block_composition "standard", "ktk",  ["ths", "bng", "jou", "m15", "ktk"]
    assert_block_composition "standard", "m15",  ["rtr", "gtc", "dgm", "m14", "ths", "bng", "jou", "m15"]
    assert_block_composition "standard", "jou",  ["rtr", "gtc", "dgm", "m14", "ths", "bng", "jou"]
    assert_block_composition "standard", "bng",  ["rtr", "gtc", "dgm", "m14", "ths", "bng"]
    assert_block_composition "standard", "ths",  ["rtr", "gtc", "dgm", "m14", "ths"]
    assert_block_composition "standard", "m14",  ["isd", "dka", "avr", "m13", "rtr", "gtc", "dgm", "m14"]
    assert_block_composition "standard", "dgm",  ["isd", "dka", "avr", "m13", "rtr", "gtc", "dgm"]
    assert_block_composition "standard", "gtc",  ["isd", "dka", "avr", "m13", "rtr", "gtc"]
    assert_block_composition "standard", "rtr",  ["isd", "dka", "avr", "m13", "rtr"]
    assert_block_composition "standard", "m13",  ["som", "mbs", "nph", "m12", "isd", "dka", "avr", "m13"]
    assert_block_composition "standard", "avr",  ["som", "mbs", "nph", "m12", "isd", "dka", "avr"]
    assert_block_composition "standard", "dka",  ["som", "mbs", "nph", "m12", "isd", "dka"]
    assert_block_composition "standard", "isd",  ["som", "mbs", "nph", "m12", "isd"]
    assert_block_composition "standard", "m12",  ["zen", "wwk", "roe", "m11", "som", "mbs", "nph", "m12"],
      "Jace, the Mind Sculptor" => "banned",
      "Stoneforge Mystic" => "banned"
    assert_block_composition "standard", Date.parse("2011-07-01"), ["zen", "wwk", "roe", "m11", "som", "mbs", "nph"],
      "Jace, the Mind Sculptor" => "banned",
      "Stoneforge Mystic" => "banned"
    assert_block_composition "standard", "nph",  ["zen", "wwk", "roe", "m11", "som", "mbs", "nph"]
    assert_block_composition "standard", "mbs",  ["zen", "wwk", "roe", "m11", "som", "mbs"]
    assert_block_composition "standard", "som",  ["zen", "wwk", "roe", "m11", "som"]
    assert_block_composition "standard", "m11",  ["ala", "cfx", "arb", "m10", "zen", "wwk", "roe", "m11"]
    assert_block_composition "standard", "roe",  ["ala", "cfx", "arb", "m10", "zen", "wwk", "roe"]
    assert_block_composition "standard", "wwk",  ["ala", "cfx", "arb", "m10", "zen", "wwk"]
    assert_block_composition "standard", "zen",  ["ala", "cfx", "arb", "m10", "zen"]
    assert_block_composition "standard", "m10",  ["lw", "mt", "shm", "eve", "ala", "cfx", "arb", "m10"]
    assert_block_composition "standard", "arb",  ["10e", "lw", "mt", "shm", "eve", "ala", "cfx", "arb"]
    assert_block_composition "standard", "cfx",  ["10e", "lw", "mt", "shm", "eve", "ala", "cfx"]
    assert_block_composition "standard", "ala",  ["10e", "lw", "mt", "shm", "eve", "ala"]
    assert_block_composition "standard", "eve",  ["cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt", "shm", "eve"]
    assert_block_composition "standard", "shm",  ["cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt", "shm"]
    assert_block_composition "standard", "mt",   ["cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt"]
    assert_block_composition "standard", "lw",   ["cs", "ts", "tsts", "pc", "fut", "10e", "lw"]
    assert_block_composition "standard", "10e",  ["rav", "gp", "di", "cs", "ts", "tsts", "pc", "fut", "10e"]
    assert_block_composition "standard", "fut",  ["9e", "rav", "gp", "di", "cs", "ts", "tsts", "pc", "fut"]
    assert_block_composition "standard", "pc",   ["9e", "rav", "gp", "di", "cs", "ts", "tsts", "pc"]
    assert_block_composition "standard", "tsts", ["9e", "rav", "gp", "di", "cs", "ts", "tsts"]
    assert_block_composition "standard", "ts",   ["9e", "rav", "gp", "di", "cs", "ts", "tsts"]
    assert_block_composition "standard", "cs",   ["chk", "bok", "sok", "9e", "rav", "gp", "di", "cs"]
    assert_block_composition "standard", "di",   ["chk", "bok", "sok", "9e", "rav", "gp", "di"]
    assert_block_composition "standard", "gp",   ["chk", "bok", "sok", "9e", "rav", "gp"]
    assert_block_composition "standard", "rav",  ["chk", "bok", "sok", "9e", "rav"]
    assert_block_composition "standard", "9e",   ["mi", "ds", "5dn", "chk", "bok", "sok", "9e"],
      "Ancient Den" => "banned",
      "Arcbound Ravager" => "banned",
      "Darksteel Citadel" => "banned",
      "Disciple of the Vault" => "banned",
      "Great Furnace" => "banned",
      "Seat of the Synod" => "banned",
      "Skullclamp" => "banned",
      "Tree of Tales" => "banned",
      "Vault of Whispers" => "banned"
    assert_block_composition "standard", "sok",  ["8e", "mi", "ds", "5dn", "chk", "bok", "sok"],
      "Ancient Den" => "banned",
      "Arcbound Ravager" => "banned",
      "Darksteel Citadel" => "banned",
      "Disciple of the Vault" => "banned",
      "Great Furnace" => "banned",
      "Seat of the Synod" => "banned",
      "Skullclamp" => "banned",
      "Tree of Tales" => "banned",
      "Vault of Whispers" => "banned"
    assert_block_composition "standard", "bok",  ["8e", "mi", "ds", "5dn", "chk", "bok"],
      "Skullclamp" => "banned"
    assert_block_composition "standard", "chk",  ["8e", "mi", "ds", "5dn", "chk"],
      "Skullclamp" => "banned"
    assert_block_composition "standard", "5dn",  ["on", "le", "sc", "8e", "mi", "ds", "5dn"]
    assert_block_composition "standard", "ds",   ["on", "le", "sc", "8e", "mi", "ds"]
    assert_block_composition "standard", "mi",   ["on", "le", "sc", "8e", "mi"]
    assert_block_composition "standard", "8e",   ["od", "tr", "ju", "on", "le", "sc", "8e"]

    # Weird things happening from this point back..., ap came after 7e but will rotate earlier if I understand correctly
    # It's not guarenteed to be correct

    assert_block_composition "standard", "sc",   ["7e", "od", "tr", "ju", "on", "le", "sc"]
    assert_block_composition "standard", "le",   ["7e", "od", "tr", "ju", "on", "le"]
    assert_block_composition "standard", "on",   ["7e", "od", "tr", "ju", "on"]
    assert_block_composition "standard", "ju",   ["in", "ps", "7e", "ap", "od", "tr", "ju"]
    assert_block_composition "standard", "tr",   ["in", "ps", "7e", "ap", "od", "tr"]
    assert_block_composition "standard", "od",   ["in", "ps", "7e", "ap", "od"]
    assert_block_composition "standard", "ap",   ["mm", "ne", "pr", "in", "ps", "7e", "ap"]
    assert_block_composition "standard", "7e",   ["mm", "ne", "pr", "in", "ps", "7e"]
    assert_block_composition "standard", "ps",   ["6e", "mm", "ne", "pr", "in", "ps"]
    assert_block_composition "standard", "in",   ["6e", "mm", "ne", "pr", "in"]
    assert_block_composition "standard", "pr",   ["us", "ul", "6e", "ud", "mm", "ne", "pr"],
      "Fluctuator" => "banned",
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "ne",   ["us", "ul", "6e", "ud", "mm", "ne"],
      "Fluctuator" => "banned",
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "mm",   ["us", "ul", "6e", "ud", "mm"],
      "Fluctuator" => "banned",
      "Memory Jar" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "ud",   ["tp", "sh", "ex", "us", "ul", "6e", "ud"],
      "Dream Halls" => "banned",
      "Earthcraft" => "banned",
      "Fluctuator" => "banned",
      "Lotus Petal" => "banned",
      "Memory Jar" => "banned",
      "Recurring Nightmare" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "6e",   ["tp", "sh", "ex", "us", "ul", "6e"],
      "Dream Halls" => "banned",
      "Earthcraft" => "banned",
      "Fluctuator" => "banned",
      "Lotus Petal" => "banned",
      "Memory Jar" => "banned",
      "Recurring Nightmare" => "banned",
      "Time Spiral" => "banned",
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "ul",   ["5e", "tp", "sh", "ex", "us", "ul"],
      "Tolarian Academy" => "banned",
      "Windfall" => "banned"
    assert_block_composition "standard", "us",   ["5e", "tp", "sh", "ex", "us"]
    assert_block_composition "standard", "ex",   ["mr", "vi", "5e", "wl", "tp", "sh", "ex"]
    assert_block_composition "standard", "sh",   ["mr", "vi", "5e", "wl", "tp", "sh"]
    assert_block_composition "standard", "tp",   ["mr", "vi", "5e", "wl", "tp"]

    # There aren't clear blocks going that far back
    # There was also time when Standard had ABUR duals explicitly added to it...
    # This ought to be fixed someday, but it's not urgent

    # assert_block_composition "standard", "wl",   [???, "mr", "vi", "5e", "wl"]
    # assert_block_composition "standard", "5e",   [???]
    # assert_block_composition "standard", "vi",   [???]
    # assert_block_composition "standard", "mr",   [???]
    # assert_block_composition "standard", "ai",   [???]
    # assert_block_composition "standard", "hl",   [???]
    # assert_block_composition "standard", "ia",   [???]
    # assert_block_composition "standard", "4e",   [???]
    # assert_block_composition "standard", "fe",   [???]
    # assert_block_composition "standard", "dk",   [???]
    # assert_block_composition "standard", "lg",   [???]
    # assert_block_composition "standard", "rv",   [???]
    # assert_block_composition "standard", "aq",   [???]
    # assert_block_composition "standard", "un",   [???]
    # assert_block_composition "standard", "an",   [???]
    # assert_block_composition "standard", "be",   [???]
    # assert_block_composition "standard", "al",   [???]
  end

  ## Eternal formats

  it "legacy" do
    assert_block_composition "legacy", "ema", ["al", "be", "un", "an", "ced", "cedi", "drc", "aq", "rv", "lg", "dk", "fe", "dcilm", "mbp", "4e", "ia", "ch", "hl", "ai", "rqs",  "mr", "mgbc", "itp", "vi", "5e", "pot", "po", "van", "wl", "ptc", "tp", "sh", "po2", "jr", "ex", "apac", "us", "at", "ul", "6e", "p3k", "ud", "st", "guru", "wrl", "wotc", "mm", "br", "sus", "fnmp", "euro", "ne", "st2k", "pr", "bd", "in", "ps", "7e", "mprp", "ap", "od", "dm", "tr", "ju", "on", "le", "sc", "8e", "mi", "ds", "5dn", "chk", "bok", "sok", "9e", "rav", "thgt", "gp", "cp", "di", "cstd", "cs", "tsts", "ts", "pc", "pro", "gpx", "fut", "10e", "mgdc", "sum", "med", "lw", "evg", "mt", "mlp", "15ann", "shm", "eve", "fvd", "me2", "ala", "jvc", "cfx", "dvd", "arb", "m10", "fve", "pch", "me3", "zen", "gvl", "pds", "wwk", "pvc", "roe", "dpa", "arc", "m11", "fvr", "ddf", "som", "pd2", "me4", "mbs", "ddg", "nph", "cmd", "m12", "fvl", "ddh", "isd", "pd3", "dka", "ddi", "avr", "pc2", "m13", "v12", "ddj", "rtr", "cma", "gtc", "ddk", "wmcq", "dgm", "mma", "m14", "v13", "ddl", "ths", "c13", "bng", "ddm", "jou", "md1", "cns", "vma", "m15", "cp1", "cp2", "cp3", "v14", "ddn", "ktk", "c14", "ddaevg", "ddadvd", "ddagvl", "ddajvc", "ugin", "frf", "ddo", "dtk", "tpr", "mm2", "ori", "v15", "ddp", "bfz", "exp", "c15", "ogw", "ddq", "w16", "soi", "ema"],
      "Amulet of Quoz" => "banned",
      "Ancestral Recall" => "banned",
      "Balance" => "banned",
      "Bazaar of Baghdad" => "banned",
      "Black Lotus" => "banned",
      "Bronze Tablet" => "banned",
      "Channel" => "banned",
      "Chaos Orb" => "banned",
      "Contract from Below" => "banned",
      "Darkpact" => "banned",
      "Demonic Attorney" => "banned",
      "Demonic Consultation" => "banned",
      "Demonic Tutor" => "banned",
      "Dig Through Time" => "banned",
      "Earthcraft" => "banned",
      "Falling Star" => "banned",
      "Fastbond" => "banned",
      "Flash" => "banned",
      "Frantic Search" => "banned",
      "Goblin Recruiter" => "banned",
      "Gush" => "banned",
      "Hermit Druid" => "banned",
      "Imperial Seal" => "banned",
      "Jeweled Bird" => "banned",
      "Library of Alexandria" => "banned",
      "Mana Crypt" => "banned",
      "Mana Drain" => "banned",
      "Mana Vault" => "banned",
      "Memory Jar" => "banned",
      "Mental Misstep" => "banned",
      "Mind Twist" => "banned",
      "Mind's Desire" => "banned",
      "Mishra's Workshop" => "banned",
      "Mox Emerald" => "banned",
      "Mox Jet" => "banned",
      "Mox Pearl" => "banned",
      "Mox Ruby" => "banned",
      "Mox Sapphire" => "banned",
      "Mystical Tutor" => "banned",
      "Necropotence" => "banned",
      "Oath of Druids" => "banned",
      "Rebirth" => "banned",
      "Shahrazad" => "banned",
      "Skullclamp" => "banned",
      "Sol Ring" => "banned",
      "Strip Mine" => "banned",
      "Survival of the Fittest" => "banned",
      "Tempest Efreet" => "banned",
      "Time Vault" => "banned",
      "Time Walk" => "banned",
      "Timetwister" => "banned",
      "Timmerian Fiends" => "banned",
      "Tinker" => "banned",
      "Tolarian Academy" => "banned",
      "Treasure Cruise" => "banned",
      "Vampiric Tutor" => "banned",
      "Wheel of Fortune" => "banned",
      "Windfall" => "banned",
      "Yawgmoth's Bargain" => "banned",
      "Yawgmoth's Will" => "banned"

    assert_legality "legacy", Date.parse("2005.1.1"), "Zodiac Dog", nil
    assert_legality "legacy", Date.parse("2006.1.1"), "Zodiac Dog", "legal"
  end

  it "vintage" do
    assert_block_composition "vintage", "ema", ["al", "be", "un", "an", "ced", "cedi", "drc", "aq", "rv", "lg", "dk", "fe", "dcilm", "mbp", "4e", "ia", "ch", "hl", "ai", "rqs",  "mr", "mgbc", "itp", "vi", "5e", "pot", "po", "van", "wl", "ptc", "tp", "sh", "po2", "jr", "ex", "apac", "us", "at", "ul", "6e", "p3k", "ud", "st", "guru", "wrl", "wotc", "mm", "br", "sus", "fnmp", "euro", "ne", "st2k", "pr", "bd", "in", "ps", "7e", "mprp", "ap", "od", "dm", "tr", "ju", "on", "le", "sc", "8e", "mi", "ds", "5dn", "chk", "bok", "sok", "9e", "rav", "thgt", "gp", "cp", "di", "cstd", "cs", "tsts", "ts", "pc", "pro", "gpx", "fut", "10e", "mgdc", "sum", "med", "lw", "evg", "mt", "mlp", "15ann", "shm", "eve", "fvd", "me2", "ala", "jvc", "cfx", "dvd", "arb", "m10", "fve", "pch", "me3", "zen", "gvl", "pds", "wwk", "pvc", "roe", "dpa", "arc", "m11", "fvr", "ddf", "som", "pd2", "me4", "mbs", "ddg", "nph", "cmd", "m12", "fvl", "ddh", "isd", "pd3", "dka", "ddi", "avr", "pc2", "m13", "v12", "ddj", "rtr", "cma", "gtc", "ddk", "wmcq", "dgm", "mma", "m14", "v13", "ddl", "ths", "c13", "bng", "ddm", "jou", "md1", "cns", "vma", "m15", "cp1", "cp2", "cp3", "v14", "ddn", "ktk", "c14", "ddaevg", "ddadvd", "ddagvl", "ddajvc", "ugin", "frf", "ddo", "dtk", "tpr", "mm2", "ori", "v15", "ddp", "bfz", "exp", "c15", "ogw", "ddq", "w16", "soi", "ema"],
      "Amulet of Quoz" => "banned",
      "Ancestral Recall" => "restricted",
      "Balance" => "restricted",
      "Black Lotus" => "restricted",
      "Brainstorm" => "restricted",
      "Bronze Tablet" => "banned",
      "Chalice of the Void" => "restricted",
      "Channel" => "restricted",
      "Chaos Orb" => "banned",
      "Contract from Below" => "banned",
      "Darkpact" => "banned",
      "Demonic Attorney" => "banned",
      "Demonic Consultation" => "restricted",
      "Demonic Tutor" => "restricted",
      "Dig Through Time" => "restricted",
      "Falling Star" => "banned",
      "Fastbond" => "restricted",
      "Flash" => "restricted",
      "Imperial Seal" => "restricted",
      "Jeweled Bird" => "banned",
      "Library of Alexandria" => "restricted",
      "Lion's Eye Diamond" => "restricted",
      "Lodestone Golem" => "restricted",
      "Lotus Petal" => "restricted",
      "Mana Crypt" => "restricted",
      "Mana Vault" => "restricted",
      "Memory Jar" => "restricted",
      "Merchant Scroll" => "restricted",
      "Mind's Desire" => "restricted",
      "Mox Emerald" => "restricted",
      "Mox Jet" => "restricted",
      "Mox Pearl" => "restricted",
      "Mox Ruby" => "restricted",
      "Mox Sapphire" => "restricted",
      "Mystical Tutor" => "restricted",
      "Necropotence" => "restricted",
      "Ponder" => "restricted",
      "Rebirth" => "banned",
      "Shahrazad" => "banned",
      "Sol Ring" => "restricted",
      "Strip Mine" => "restricted",
      "Tempest Efreet" => "banned",
      "Time Vault" => "restricted",
      "Time Walk" => "restricted",
      "Timetwister" => "restricted",
      "Timmerian Fiends" => "banned",
      "Tinker" => "restricted",
      "Tolarian Academy" => "restricted",
      "Treasure Cruise" => "restricted",
      "Trinisphere" => "restricted",
      "Vampiric Tutor" => "restricted",
      "Wheel of Fortune" => "restricted",
      "Windfall" => "restricted",
      "Yawgmoth's Bargain" => "restricted",
      "Yawgmoth's Will" => "restricted"

    assert_legality "legacy", Date.parse("2005.1.1"), "Zodiac Dog", nil
    assert_legality "legacy", Date.parse("2006.1.1"), "Zodiac Dog", "legal"
  end

  it "commander" do
    assert_legality "legacy", Date.parse("2005.1.1"), "Zodiac Dog", nil
    assert_legality "legacy", Date.parse("2006.1.1"), "Zodiac Dog", "legal"
  end

  ## Sanity check that no sets were skipped
  it "sanity check" do
    standard_sets = db.sets.values.select{|s| s.type == "core" or s.type == "expansion"} + [
      db.sets["w16"], db.sets["w17"]
    ]
    FormatFrontier.new.build_included_sets.should eq(
      standard_sets.select{|s| s.release_date >= Date.parse("2014-07-18") }.map(&:code).to_set
    )
    FormatModern.new.build_included_sets.should eq(
      standard_sets.select{|s| s.release_date >= Date.parse("2003-07-28") }.map(&:code).to_set
    )
    FormatStandard.new.rotation_schedule.values.flatten.uniq.to_set.should eq(
      standard_sets.select{|s| s.release_date >= Date.parse("1996-10-08") }.map(&:code).to_set
    )
  end

  ## Other formats

  it "pauper" do
    assert_legality "pauper", "rav", "Blazing Torch", nil
    assert_legality "pauper", "zen", "Blazing Torch", nil
    assert_legality "pauper", "isd", "Blazing Torch", "legal"

    assert_legality "vintage", "rav", "Blazing Torch", nil
    assert_legality "vintage", "zen", "Blazing Torch", "legal"
    assert_legality "vintage", "isd", "Blazing Torch", "legal"
  end

  # We don't have historical legality for Duel Commander yet,
  # maybe add it at some later point
  it "duel commander" do
    assert_count_results 'banned:"duel commander"', 57
    assert_count_results 'restricted:"duel commander"', 10
  end

  # We don't have historical legality for Petty Dreadful yet
  it "penny dreadful" do
    assert_search_include 'f:"penny dreadful"', *FormatPennyDreadful::PrimaryCards
    assert_search_results 'f:"penny dreadful"', *FormatPennyDreadful.all_cards(db)
    # If card is in Penny Dreadful, its other side is as well
    # (except for meld cards)
    assert_search_results "f:pd other:-f:pd -is:meld"
  end

  ## TODO - Extended, and various weirdo formats
end
