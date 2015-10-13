require "set"

BanLists = {
  "Ancestral Recall"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Balance"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Black Lotus"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Channel"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Chaos Orb"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Contract from Below"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Darkpact"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Demonic Attorney"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Demonic Tutor"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Fastbond"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Mana Vault"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Mind Twist"=>{"legacy"=>"banned"},
  "Mox Emerald"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Mox Jet"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Mox Pearl"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Mox Ruby"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Mox Sapphire"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Sol Ring"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Time Vault"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Time Walk"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Timetwister"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Wheel of Fortune"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Bazaar of Baghdad"=>{"legacy"=>"banned"},
  "Jeweled Bird"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Library of Alexandria"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Shahrazad"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Bronze Tablet"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Mishra's Workshop"=>{"legacy"=>"banned"},
  "Strip Mine"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Falling Star"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Karakas"=>{"commander"=>"banned"},
  "Mana Drain"=>{"legacy"=>"banned"},
  "Rebirth"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Tempest Efreet"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Mana Crypt"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Amulet of Quoz"=>{"commander"=>"banned", "ice age block"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Brainstorm"=>{"vintage"=>"restricted"},
  "Demonic Consultation"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Necropotence"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Zuran Orb"=>{"ice age block"=>"banned"},
  "Merchant Scroll"=>{"vintage"=>"restricted"},
  "Timmerian Fiends"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Thawing Glaciers"=>{"ice age block"=>"banned"},
  "Flash"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Lion's Eye Diamond"=>{"vintage"=>"restricted"},
  "Mystical Tutor"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Goblin Recruiter"=>{"legacy"=>"banned"},
  "Squandered Resources"=>{"mirage block"=>"banned"},
  "Vampiric Tutor"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Dig Through Time"=>{"legacy"=>"banned", "modern"=>"banned", "vintage"=>"restricted"},
  "Emrakul, the Aeons Torn"=>{"commander"=>"banned"},
  "Cursed Scroll"=>{"tempest block"=>"banned"},
  "Earthcraft"=>{"legacy"=>"banned"},
  "Lotus Petal"=>{"vintage"=>"restricted"},
  "Hermit Druid"=>{"legacy"=>"banned"},
  "Gaea's Cradle"=>{"urza block"=>"banned"},
  "Mind's Desire"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Oath of Druids"=>{"legacy"=>"banned"},
  "Survival of the Fittest"=>{"legacy"=>"banned"},
  "Yawgmoth's Will"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Limited Resources"=>{"commander"=>"banned"},
  "Recurring Nightmare"=>{"commander"=>"banned"},
  "Serra's Sanctum"=>{"urza block"=>"banned"},
  "Time Spiral"=>{"urza block"=>"banned"},
  "Tolarian Academy"=>{"commander"=>"banned", "legacy"=>"banned", "urza block"=>"banned", "vintage"=>"restricted"},
  "Voltaic Key"=>{"urza block"=>"banned"},
  "Windfall"=>{"legacy"=>"banned", "urza block"=>"banned", "vintage"=>"restricted"},
  "Frantic Search"=>{"legacy"=>"banned"},
  "Memory Jar"=>{"legacy"=>"banned", "urza block"=>"banned", "vintage"=>"restricted"},
  "Tinker"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Imperial Seal"=>{"legacy"=>"banned", "vintage"=>"restricted"},
  "Rofellos, Llanowar Emissary"=>{"commander"=>"banned"},
  "Yawgmoth's Bargain"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"restricted"},
  "Gush"=>{"legacy"=>"banned"},
  "Rishadan Port"=>{"masques block"=>"banned"},
  "Bloodbraid Elf"=>{"modern"=>"banned"},
  "Cloudpost"=>{"modern"=>"banned"},
  "Lingering Souls"=>{"innistrad block"=>"banned"},
  "Lin Sivvi, Defiant Hero"=>{"masques block"=>"banned"},
  "Coalition Victory"=>{"commander"=>"banned"},
  "Ponder"=>{"modern"=>"banned", "vintage"=>"restricted"},
  "Braids, Cabal Minion"=>{"commander"=>"banned"},
  "Upheaval"=>{"commander"=>"banned"},
  "Biorhythm"=>{"commander"=>"banned"},
  "Trade Secrets"=>{"commander"=>"banned"},
  "Ancient Den"=>{"modern"=>"banned", "mirrodin block"=>"banned"},
  "Chalice of the Void"=>{"vintage"=>"restricted"},
  "Chrome Mox"=>{"modern"=>"banned"},
  "Disciple of the Vault"=>{"mirrodin block"=>"banned"},
  "Great Furnace"=>{"modern"=>"banned", "mirrodin block"=>"banned"},
  "Seat of the Synod"=>{"modern"=>"banned", "mirrodin block"=>"banned"},
  "Second Sunrise"=>{"modern"=>"banned"},
  "Seething Song"=>{"modern"=>"banned"},
  "Tree of Tales"=>{"modern"=>"banned", "mirrodin block"=>"banned"},
  "Vault of Whispers"=>{"modern"=>"banned", "mirrodin block"=>"banned"},
  "Æther Vial"=>{"mirrodin block"=>"banned"},
  "Arcbound Ravager"=>{"mirrodin block"=>"banned"},
  "Darksteel Citadel"=>{"mirrodin block"=>"banned"},
  "Panoptic Mirror"=>{"commander"=>"banned"},
  "Skullclamp"=>{"legacy"=>"banned", "modern"=>"banned", "mirrodin block"=>"banned"},
  "Sundering Titan"=>{"commander"=>"banned"},
  "Trinisphere"=>{"vintage"=>"restricted"},
  "Gifts Ungiven"=>{"commander"=>"banned"},
  "Glimpse of Nature"=>{"modern"=>"banned"},
  "Sensei's Divining Top"=>{"modern"=>"banned"},
  "Blazing Shoal"=>{"modern"=>"banned"},
  "Sway of the Stars"=>{"commander"=>"banned"},
  "Umezawa's Jitte"=>{"modern"=>"banned"},
  "Erayo's Essence"=>{"commander"=>"banned"},
  "Erayo, Soratami Ascendant"=>{"commander"=>"banned"},
  "Protean Hulk"=>{"commander"=>"banned"},
  "Dark Depths"=>{"modern"=>"banned"},
  "Rite of Flame"=>{"modern"=>"banned"},
  "Ancestral Vision"=>{"modern"=>"banned"},
  "Dread Return"=>{"modern"=>"banned"},
  "Hypergenesis"=>{"modern"=>"banned"},
  "Griselbrand"=>{"commander"=>"banned"},
  "Primeval Titan"=>{"commander"=>"banned"},
  "Sword of the Meek"=>{"modern"=>"banned"},
  "Painter's Servant"=>{"commander"=>"banned"},
  "Punishing Fire"=>{"modern"=>"banned"},
  "Jace, the Mind Sculptor"=>{"modern"=>"banned"},
  "Stoneforge Mystic"=>{"modern"=>"banned"},
  "Preordain"=>{"modern"=>"banned"},
  "Green Sun's Zenith"=>{"modern"=>"banned"},
  "Birthing Pod"=>{"modern"=>"banned"},
  "Mental Misstep"=>{"legacy"=>"banned", "modern"=>"banned"},
  "Intangible Virtue"=>{"innistrad block"=>"banned"},
  "Worldfire"=>{"commander"=>"banned"},
  "Deathrite Shaman"=>{"modern"=>"banned"},
  "Sylvan Primordial"=>{"commander"=>"banned"},
  "Advantageous Proclamation"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Backup Plan"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Brago's Favor"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Double Stroke"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Immediate Action"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Iterative Analysis"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Muzzio's Preparations"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Power Play"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Secret Summoning"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Secrets of Paradise"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Sentinel Dispatch"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Unexpected Potential"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Worldknit"=>{"commander"=>"banned", "legacy"=>"banned", "vintage"=>"banned"},
  "Treasure Cruise"=>{"legacy"=>"banned", "modern"=>"banned", "vintage"=>"restricted"}
}

class CardLegality
  def initialize(name, sets, layout)
    @card_name = name
    @sets = sets
    @layout = layout
  end

  def legality
    return {} if ["vanguard", "token", "plane", "scheme", "phenomenon"].include?(@layout)

    formats = Set[]
    @sets.each do |set|
      case set
      when "arena", "uqc", "rep", "hho"
        # Not real printings, presumably
        next
      when "uh", "ug"
        formats << "un-sets"
        next
      when "ia", "ai"
        formats << "ice age block"
      when "cs"
        formats << "ice age block" << "modern"
      when "mr", "vi", "wl"
        formats << "mirage block"
      when "tp", "sh", "ex"
        formats << "tempest block"
      when "tp", "sh", "ex"
        formats << "tempest block"
      when "us", "ul", "ud"
        formats << "urza block"
      when "mm", "ne", "pr"
        formats << "masques block"
      when "in", "ps", "ap"
        formats << "invasion block"
      when "od", "tr", "ju"
        formats << "odyssey block"
      when "on", "le", "sc"
        formats << "onslaught block"
      when "mi", "ds", "5dn"
        formats << "modern" << "mirrodin block"
      when "chk", "bok", "sok"
        formats << "modern" << "kamigawa block"
      when "rav", "gp", "di"
        formats << "modern" << "ravnica block"
      when "ts", "tsts", "pc", "fut"
        formats << "modern" << "time spiral block"
      when "Lorwyn", "lw", "mt", "shm", "eve"
        formats << "modern" << "lorwyn-shadowmoor block"
      when "ala", "cfx", "arb"
        formats << "modern" << "shards of alara block"
      when "zen", "wwk", "roe"
        formats << "modern" << "zendikar block"
      when "som", "mbs", "nph"
        formats << "modern" << "scars of mirrodin block"
      when "isd", "dka", "avr"
        formats << "modern" << "innistrad block"
      when "rtr", "gtc", "dgm"
        formats << "modern" << "return to ravnica block"
      when "ths", "bng", "jou"
        formats << "modern" << "theros block"
      when "ktk", "frf", "dtk"
        formats << "standard" << "modern" << "tarkir block"
      when "bfz"
        formats << "standard" << "modern" # << "battle for zendikar block"
      when "8e", "9e", "10e", "m10", "m11", "m12", "m13", "m14", "m15"
        formats << "modern"
      when "ori"
        formats << "standard" << "modern"
      when "cns"
        # No easy test for draft cards
        formats << "legacy" << "vintage"
        next
      end
      formats << "commander" << "legacy" << "vintage"
    end
    leg = {}
    formats.each do |format|
      leg[format] = "legal"
    end
    leg.merge!(BanLists[@card_name]) if BanLists[@card_name]
    leg
  end
end
