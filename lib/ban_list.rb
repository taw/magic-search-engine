# Everything about it is wrong, only recently ban list changes are linked with set releases

BanListChangeDates = {
  # magic min/max, might not end up being needed
  "start" => "1900-01-01",
  "end"   => "2999-12-31",

   # originals are gone, guessing exact date based on patterns:

  "apr 1997" => "1 may 1997",
  "jun 1997" => "1 jul 1997",

  # http://members.tripod.com/blue_midget/Gossip/banned.htm
  "mar 1999" => "April 1, 1999",

  # For 1999+ annoncemenets are at:
  # http://mtg.icequake.net/www.crystalkeep.com/magic/rules/dci/

  "jun 1999" => "July 1, 1999",
  "jul 1999" => "August 1, 1999", # emergency ban
  "sep 1999" => "October 1, 1999",
  "mar 2000" => "April 1, 2000",
  "jun 2000" => "July 1, 2000",
  "sep 2000" => "October 1, 2000",
  "mar 2001" => "April 1, 2001",
  "dec 2001" => "January 1, 2002",
  "mar 2003" => "April 1, 2003",
  "jun 2003" => "July 1, 2003",

  "sep 2003" => "October 1, 2003",
  "dec 2003" => "January 1, 2004",

  "sep 2004" => "September 20, 2004",
  "dec 2004" => "December 20, 2004",
  "mar 2005" => "March 20, 2005",
  "jun 2007" => "June 20, 2007",
  "jun 2008" => "June 20, 2008",
  "sep 2005" => "September 20, 2005",
  "jun 2004" => "June 20, 2004",
  "mar 2006" => "March 20, 2006",
  "sep 2007" => "September 20, 2007",
  "sep 2008" => "September 20, 2008",

  "jun 2009" => "July 1, 2009",
  "sep 2009" => "October 1, 2009",

  "jun 2010" => "July 1, 2010",
  "sep 2010" => "October 1, 2010",
  "dec 2010" => "January 1, 2011",
  "jun 2011" => "July 1, 2011",
  # "aug 2011"   - modern annoncement, just encoded as "start"
  "sep 2011" => "2011-09-30", # "October 1, 2011" but ISD released between announcement and effective date
  "dec 2011" => "January 1, 2012",
  "mar 2012" => "April 2, 2012",
  "jun 2012" => "June 29, 2012",
  "sep 2012" => "October 1, 2012",

 # September 20, 2012 - was policy change, before that there were 4 anonucements per year
 # After that, it's linked with set release
 # This list should be culled a bit to just relevant ones
 "rtr"=>"2012-10-05",
 "gtc"=>"2013-02-01",
 "dgm"=>"2013-05-03",
 "m14"=>"2013-07-19",
 "ths"=>"2013-09-27",
 "bng"=>"2014-02-07",
 "jou"=>"2014-05-02",
 "m15"=>"2014-07-18",
 "ktk"=>"2014-09-26",
 "frf"=>"2015-01-23",
 "dtk"=>"2015-03-27",
 "ori"=>"2015-07-17",
 "bfz"=>"2015-10-02",

 # Aliases
 "may 2013" => "2013-05-03",
}

DynamicBanListData = {
  ### THESE LISTS SHOULD BE COMPLETE
  "modern" => {
    "Ancestral Vision" => "banned",
    "Ancient Den" => "banned",
    "Bitterblossom" => {"start"=>"banned", "bng" => "legal"},
    "Chrome Mox" => "banned",
    "Dark Depths" => "banned",
    "Dread Return" => "banned",
    "Glimpse of Nature" => "banned",
    "Great Furnace" => "banned",
    "Hypergenesis" => "banned",
    "Jace, the Mind Sculptor" => "banned",
    "Mental Misstep" => "banned",
    "Seat of the Synod" => "banned",
    "Sensei's Divining Top" => "banned",
    "Skullclamp" => "banned",
    "Stoneforge Mystic" => "banned",
    "Sword of the Meek" => "banned",
    "Tree of Tales" => "banned",
    "Umezawa's Jitte" => "banned",
    "Vault of Whispers" => "banned",

    "Deathrite Shaman"  => {"bng"=> "banned"},
    "Dig Through Time"  => {"frf"=> "banned"},
    "Treasure Cruise"   => {"frf"=> "banned"},
    "Birthing Pod"      => {"frf"=> "banned"},

    "Golgari Grave-Troll"  => {"start"=>"banned", "frf" => "legal"},
    "Valakut, the Molten Pinnacle" => {"start"=>"banned", "sep 2012"=>"legal"},
    "Wild Nacatl"       => {"dec 2011"=>"banned", "bng"=>"legal"},
    "Punishing Fire"    => {"dec 2011"=>"banned"},

    "Blazing Shoal"      => { "sep 2011"=>"banned"},
    "Cloudpost"          => { "sep 2011"=>"banned"},
    "Green Sun's Zenith" => { "sep 2011"=>"banned"},
    "Ponder"             => { "sep 2011"=>"banned"},
    "Preordain"          => { "sep 2011"=>"banned"},
    "Rite of Flame"      => { "sep 2011"=>"banned"},

    "Bloodbraid Elf"  => {"gtc" => "banned"},
    "Seething Song"   => {"gtc" => "banned"},
    "Second Sunrise"  => { "dgm" => "banned" },
  },
  "innistrad block" => {
    "Lingering Souls"    => {"start"=>"legal", "mar 2012"=>"banned"},
    "Intangible Virtue"  => {"start"=>"legal", "mar 2012"=>"banned"},
  },
  "pauper" => {
    # No idea when Cranial Plating was banned,
    # it says in Nov 2008 that it's already banned
    "Cranial Plating"   => {"start" => "banned"},
    "Frantic Search"    => {"jun 2011" => "banned"},
    "Empty the Warrens" => {"gtc" => "banned"},
    "Grapeshot"         => {"gtc" => "banned"},
    "Invigorate"        => {"gtc" => "banned"},
    "Cloudpost"         => {"ths" => "banned"},
    "Temporal Fissure"  => {"ths" => "banned"},
    "Treasure Cruise"   => {"dtk" => "banned"},
  },
  "two-headed giant" => {
    "Erayo, Soratami Ascendant" => {"sep 2005" => "banned"},
  },
  "masques block" => {
    "Lin Sivvi, Defiant Hero" => { "jun 2000" => "banned" },
    "Rishadan Port"           => { "jun 2000" => "banned" },
  },
  "mirrodin block" => {
    "Skullclamp"           => { "jun 2004" => "banned" },
    # WTF??? This was deep in Ravnica block
    "Aether Vial"          => { "mar 2006" => "banned" },
    "Ancient Den"          => { "mar 2006" => "banned" },
    "Arcbound Ravager"     => { "mar 2006" => "banned" },
    "Darksteel Citadel"    => { "mar 2006" => "banned" },
    "Disciple of the Vault"=> { "mar 2006" => "banned" },
    "Great Furnace"        => { "mar 2006" => "banned" },
    "Seat of the Synod"    => { "mar 2006" => "banned" },
    "Tree of Tales"        => { "mar 2006" => "banned" },
    "Vault of Whispers"    => { "mar 2006" => "banned" },
  },
  "ice age block" => {
    "Thawing Glaciers" => {"apr 1997" => "banned"},
    "Zuran Orb" => {"apr 1997" => "banned"},
  },
  "mirage block" => {
     "Squandered Resources" => {"jun 1997" => "banned"},
  },
  "urza block" => {
    "Time Spiral"     => { "mar 1999" => "banned" },
    "Memory Jar"      => { "mar 1999" => "banned" },
    "Windfall"        => { "mar 1999" => "banned" },
    "Gaea's Cradle"   => { "jun 1999" => "banned" },
    "Serra's Sanctum" => { "jun 1999" => "banned" },
    "Tolarian Academy"=> { "jun 1999" => "banned" },
    "Voltaic Key"     => { "jun 1999" => "banned" },
  },

  ### IN PROGRESS

  "standard" => {
    "Jace, the Mind Sculptor" => { "sep 2011" => "banned" },
    "Stoneforge Mystic"       => { "sep 2011" => "banned" }, # ignoring Event Deck exception
    "Skullclamp"              => { "jun 2004" => "banned" },
    "Arcbound Ravager"        => { "mar 2005" => "banned" },
    "Disciple of the Vault"   => { "mar 2005" => "banned" },
    "Darksteel Citadel"       => { "mar 2005" => "banned" },
    "Ancient Den"             => { "mar 2005" => "banned" },
    "Great Furnace"           => { "mar 2005" => "banned" },
    "Seat of the Synod"       => { "mar 2005" => "banned" },
    "Tree of Tales"           => { "mar 2005" => "banned" },
    "Vault of Whispers"       => { "mar 2005" => "banned" },
  },

  "extended" => {
    "Goblin Lackey"           => { "sep 2003" => "banned" },
    "Entomb"                  => { "sep 2003" => "banned" },
    "Frantic Search"          => { "sep 2003" => "banned" },
    "Goblin Recruiter"        => { "dec 2003" => "banned" },
    "Grim Monolith"           => { "dec 2003" => "banned" },
    "Tinker"                  => { "dec 2003" => "banned" },
    "Hermit Druid"            => { "dec 2003" => "banned" },
    "Ancient Tomb"            => { "dec 2003" => "banned" },
    "Oath of Druids"          => { "dec 2003" => "banned" },
    "Necropotence"            => { "mar 2001" => "banned" },
    "Replenish"               => { "mar 2001" => "banned" },
    "Survival of the Fittest" => { "mar 2001" => "banned" },
    "Demonic Consultation"    => { "mar 2001" => "banned" },
    "Metalworker"             => { "sep 2004" => "banned" },
    "Skullclamp"              => { "sep 2004" => "banned" },
    "Aether Vial"             => { "sep 2005" => "banned" },
    "Disciple of the Vault"   => { "sep 2005" => "banned" },
    "Sensei's Divining Top"   => { "sep 2008" => "banned" },
    "Sword of the Meek"       => { "jun 2010" => "banned" },
    "Hypergenesis"            => { "jun 2010" => "banned" },
    "Jace, the Mind Sculptor" => { "sep 2011" => "banned" },
    "Mental Misstep"          => { "sep 2011" => "banned" },
    "Ponder"                  => { "sep 2011" => "banned" },
    "Preordain"               => { "sep 2011" => "banned" },
    "Stoneforge Mystic"       => { "sep 2011" => "banned" },
  },

  ### INCOMPLETE

  "legacy" => {
    "Advantageous Proclamation" => "banned",
    "Backup Plan" => "banned",
    "Brago's Favor" => "banned",
    "Double Stroke" => "banned",
    "Immediate Action" => "banned",
    "Iterative Analysis" => "banned",
    "Muzzio's Preparations" => "banned",
    "Power Play" => "banned",
    "Secret Summoning" => "banned",
    "Secrets of Paradise" => "banned",
    "Sentinel Dispatch" => "banned",
    "Unexpected Potential" => "banned",
    "Worldknit" => "banned",

    "Imperial Seal"    => {"sep 2005" => "banned" },
    "Flash"            => {"jun 2007" => "banned" },
    "Mind Over Matter" => {"?" => "banned", "jun 2007" => "legal"},
    "Replenish"        => {"?" => "banned", "jun 2007" => "legal"},
    "Shahrazad"        => {"sep 2007" => "banned"},
    "Time Vault"       => {"sep 2008" => "banned"},

    "Dream Halls"      => {"?"=>"banned", "sep 2009" => "legal"},
    "Entomb"           => {"?"=>"banned", "sep 2009" => "legal"},
    "Metalworker"      => {"?"=>"banned", "sep 2009" => "legal"},
    "Mystical Tutor"   => {"jun 2010" => "banned"},
    "Grim Monolith"    => {"?" => "banned", "jun 2010" => "legal"},
    "Illusionary Mask" => {"?" => "banned", "jun 2010" => "legal"},
    "Survival of the Fittest" => {"dec 2010" => "banned"},
    "Time Spiral"             => {"?"=>"banned", "dec 2010" => "legal"},

    "Mental Misstep"     => {"sep 2011" => "banned"},
    "Land Tax"           => {"?"=>"banned", "jun 2012"=>"legal"},
    "Treasure Cruise"    => {"start"=>"legal", "frf"=> "banned"},
    "Worldgorger Dragon" => {"start"=>"banned", "frf"=> "legal"},
    "Dig Through Time"   => {"start"=>"legal", "bfz"=>"banned"},
    "Black Vise"         => {"start"=>"banned", "bfz"=>"legal"},
  },
  "vintage" => {
    "Advantageous Proclamation" => "banned",
    "Backup Plan" => "banned",
    "Brago's Favor" => "banned",
    "Double Stroke" => "banned",
    "Immediate Action" => "banned",
    "Iterative Analysis" => "banned",
    "Muzzio's Preparations" => "banned",
    "Power Play" => "banned",
    "Secret Summoning" => "banned",
    "Secrets of Paradise" => "banned",
    "Sentinel Dispatch" => "banned",
    "Unexpected Potential" => "banned",
    "Worldknit" => "banned",

    "Berserk"              => {"?" => "restricted", "mar 2003" => "legal"},
    "Black Vise"           => {"?" => "restricted", "jun 2007" => "legal"},
    "Braingeyser"          => {"?" => "restricted", "sep 2004" => "legal"},
    "Brainstorm"           => {"jun 2008" => "restricted"},
    "Burning Wish"         => {"dec 2003" => "restricted", "sep 2012" => "legal"},
    "Chalice of the Void"  => {"bfz"=>"restricted"},
    "Chrome Mox"           => {"dec 2003" => "restricted", "sep 2008" => "legal"},
    "Crop Rotation"        => {"?" => "restricted", "jun 2009" => "legal"},
    "Dig Through Time"     => {"bfz"=>"restricted"},
    "Doomsday"             => {"?" => "restricted", "sep 2004" => "legal"},
    "Dream Halls"          => {"?" => "restricted", "sep 2008" => "legal"},
    "Earthcraft"           => {"mar 2003" => "restricted", "sep 2004" => "legal"},
    "Enlightened Tutor"    => {"?" => "restricted", "jun 2009" => "legal"},
    "Entomb"               => {"mar 2003" => "restricted", "jun 2009" => "legal"},
    "Fact or Fiction"      => {"dec 2001"=>"restricted", "sep 2011" => "legal"},
    "Flash"                => {"jun 2008" => "restricted"},
    "Fork"                 => {"?" => "restricted", "sep 2004" => "legal"},
    "Frantic Search"       => {"?" => "restricted", "sep 2010" => "legal"},
    "Gifts Ungiven"        => {"jun 2007"=>"restricted", "frf"=> "legal"},
    "Grim Monolith"        => {"?" => "restricted", "jun 2009" => "legal"},
    "Gush"                 => {"jun 2003" => "restricted", "jun 2007" => "legal", "jun 2008" => "restricted", "sep 2010" => "legal"},
    "Hurkyl's Recall"      => {"?" => "restricted", "mar 2003" => "legal"},
    "Imperial Seal"        => {"sep 2005" => "restricted"},
    "Lion's Eye Diamond"   => {"dec 2003" => "restricted"},
    "Merchant Scroll"      => {"jun 2008" => "restricted"},
    "Mind Over Matter"     => {"?" => "restricted", "sep 2005" => "legal"},
    "Mind Twist"           => {"?" => "restricted", "jun 2007" => "legal"},
    "Mind's Desire"        => {"jun 2003" => "restricted"},
    "Mox Diamond"          => {"?" => "restricted", "sep 2008" => "legal"},
    "Personal Tutor"       => {"sep 2005" => "restricted", "sep 2008" => "legal"},
    "Ponder"               => {"jun 2008" => "restricted"},
    "Recall"               => {"?" => "restricted", "mar 2003" => "legal"},
    "Regrowth"             => {"?" => "restricted", "may 2013" => "legal"},
    "Shahrazad"            => {"sep 2007" => "banned"},
    "Stroke of Genius"     => {"?" => "restricted", "dec 2004" => "legal"},
    "Thirst for Knowledge" => {"jun 2009"=>"restricted", "bfz"=>"legal"},
    "Time Spiral"          => {"?" => "restricted", "sep 2008" => "legal"},
    "Time Vault"           => {"sep 2008" => "restricted"},
    "Treasure Cruise"      => {"frf"=> "restricted"},
    "Trinisphere"          => {"mar 2005" => "restricted"},
    "Voltaic Key"          => {"?" => "restricted", "jun 2007" => "legal"},
  },
}

class BanList
  attr_reader :dates, :bans
  def initialize
    @dates = Hash[BanListChangeDates.map{|key, date| [key, Date.parse(date)]}]
    @bans = Hash[DynamicBanListData.map do |format, changes|
      [format, parse_changes(changes)]
    end]
  end

  # Response is: "banned", "restricted", nil
  # nil could mean legal or not depending on printing
  # It's not this class's business to decide that
  def legality(format, card_name, time)
    legality = @bans.fetch(format, {}).fetch(card_name, {})
    status = "legal"
    legality.each do |change_time,leg|
      break if change_time > time
      status = leg
    end
    status
  end

  def full_ban_list(format, time)
    result = {}
    @bans.fetch(format, {}).keys.each do |card_name|
      status = legality(format, card_name, time)
      result[card_name] = status unless status == "legal"
    end
    result
  end

  private

  def parse_changes(changes)
    seen_warns = Set[]
    Hash[changes.map{|card, legalities|
      legalities = {"start" => legalities} if legalities.is_a?(String)
      legalities = legalities.map{|dat, leg|
        unless @dates[dat]
          warn "Unknown date: #{dat}" unless seen_warns.include?(dat)
          seen_warns << dat
          next
        end # temporary until this list is finished
        [@dates[dat], leg]
      }.compact
      [card, legalities]
    }]
  end
end
