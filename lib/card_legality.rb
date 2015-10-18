require "set"
require_relative "ban_list"

BanListData = {
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
  "Treasure Cruise"=>{"legacy"=>"banned", "modern"=>"banned", "vintage"=>"restricted"}
}

SetLegality = {
  "ia" => ["ice age block"],
  "ai" => ["ice age block"],
  "cs" => ["ice age block", "modern"],
  "mr" => ["mirage block"],
  "vi" => ["mirage block"],
  "wl" => ["mirage block"],
  "tp" => ["tempest block"],
  "sh" => ["tempest block"],
  "ex" => ["tempest block"],
  "us" => ["urza block"],
  "ul" => ["urza block"],
  "ud" => ["urza block"],
  "mm" => ["masques block"],
  "ne" => ["masques block"],
  "pr" => ["masques block"],
  "in" => ["invasion block"],
  "ps" => ["invasion block"],
  "ap" => ["invasion block"],
  "od" => ["odyssey block"],
  "tr" => ["odyssey block"],
  "ju" => ["odyssey block"],
  "on" => ["onslaught block"],
  "le" => ["onslaught block"],
  "sc" => ["onslaught block"],
  "mi" => ["modern", "mirrodin block"],
  "ds" => ["modern", "mirrodin block"],
  "5dn" => ["modern", "mirrodin block"],
  "chk" => ["modern", "kamigawa block"],
  "bok" => ["modern", "kamigawa block"],
  "sok" => ["modern", "kamigawa block"],
  "rav" => ["modern", "ravnica block"],
  "gp" => ["modern", "ravnica block"],
  "di" => ["modern", "ravnica block"],
  "ts" => ["modern", "time spiral block"],
  "tsts" => ["modern", "time spiral block"],
  "pc" => ["modern", "time spiral block"],
  "fut" => ["modern", "time spiral block"],
  "lw" => ["modern", "lorwyn-shadowmoor block"],
  "mt" => ["modern", "lorwyn-shadowmoor block"],
  "shm" => ["modern", "lorwyn-shadowmoor block"],
  "eve" => ["modern", "lorwyn-shadowmoor block"],
  "ala" => ["modern", "shards of alara block"],
  "cfx" => ["modern", "shards of alara block"],
  "arb" => ["modern", "shards of alara block"],
  "zen" => ["modern", "zendikar block"],
  "wwk" => ["modern", "zendikar block"],
  "roe" => ["modern", "zendikar block"],
  "som" => ["modern", "scars of mirrodin block"],
  "mbs" => ["modern", "scars of mirrodin block"],
  "nph" => ["modern", "scars of mirrodin block"],
  "isd" => ["modern", "innistrad block"],
  "dka" => ["modern", "innistrad block"],
  "avr" => ["modern", "innistrad block"],
  "rtr" => ["modern", "return to ravnica block"],
  "gtc" => ["modern", "return to ravnica block"],
  "dgm" => ["modern", "return to ravnica block"],
  "ths" => ["modern", "theros block"],
  "bng" => ["modern", "theros block"],
  "jou" => ["modern", "theros block"],
  "ktk" => ["standard", "modern", "tarkir block"],
  "frf" => ["standard", "modern", "tarkir block"],
  "dtk" => ["standard", "modern", "tarkir block"],
  "bfz" => ["standard", "modern"],
  "8e" => ["modern"],
  "9e" => ["modern"],
  "10e" => ["modern"],
  "m10" => ["modern"],
  "m11" => ["modern"],
  "m12" => ["modern"],
  "m13" => ["modern"],
  "m14" => ["modern"],
  "m15" => ["modern"],
  "ori" => ["standard", "modern"],
}

class CardLegality
  def initialize(name, sets, layout, types)
    @card_name = name
    @unsets = sets.include?("uh") || sets.include?("ug")
    @cns = sets.include?("cns")
    @sets = sets - %W[arena uqc rep hho uh ug cns] # Ignore un and weirdo printings
    @extra_layout = ["vanguard", "token", "plane", "scheme", "phenomenon"].include?(layout)
    @conspiracy = types.include?("conspiracy")
    @cache = {}
  end

  def all_legalities
    legalities = {}
    [
      "commander",
      "ice age block",
      "innistrad block",
      "invasion block",
      "kamigawa block",
      "legacy",
      "lorwyn-shadowmoor block",
      "masques block",
      "mirage block",
      "mirrodin block",
      "modern",
      "odyssey block",
      "onslaught block",
      "ravnica block",
      "return to ravnica block",
      "scars of mirrodin block",
      "shards of alara block",
      "standard",
      "tarkir block",
      "tempest block",
      "theros block",
      "time spiral block",
      "un-sets",
      "urza block",
      "vintage",
      "zendikar block",
    ].each do |format|
      legalities[format] = legality(format)
    end
    legalities.compact
  end

  def legality(format)
    unless @cache.has_key?(format)
      @cache[format] = begin
        eternal_format = ["commander", "legacy", "vintage"].include?(format)
        if @extra_layout
          nil
        elsif format == "un-sets"
          @unsets ? "legal" : nil
        elsif @conspiracy
          eternal_format ? "banned" : nil
        else
          legality = nil
          if eternal_format
            legality = "legal" if !@sets.empty?
            legality = "legal" if @cns and format != "commander"
          else
            legality = "legal" if @sets.any?{|set| SetLegality.fetch(set, []).include?(format) }
          end
          if legality
            BanListData.fetch(@card_name, {}).fetch(format, legality)
          else
            nil
          end
        end
      end
    end
    @cache[format]
  end
end
