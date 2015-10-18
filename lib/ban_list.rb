# Everything about it is wrong, only recently ban list changes are linked with set releases

SetReleaseDates = {
  # magic min/max, might not end up being needed
  "start" => "1900-01-01",
  "end"   => "2999-12-31",

  # Regular announcements

  # "mar 2004"
  # "jun 2004"
  # "sep 2004"
  # "dec 2004"
  # "mar 2005"
  # "jun 2005"
  "sep 2005" => "September 20, 2005",
  # "dec 2005"
  # "mar 2006"
  # "jun 2006"
  # "sep 2006"
  # "dec 2006"
  # "mar 2007"
  # "jun 2007"
  # "sep 2007"
  # "dec 2007"
  # "mar 2008"
  # "jun 2008"
  # "sep 2008"
  # "dec 2008"
  # "mar 2009" - no changes
  # "jun 2009"
  # "sep 2009"
  # "dec 2009" - no changes
  # "mar 2010" - no changes
  # "jun 2010"
  # "sep 2010"
  # "dec 2010"

  # "mar 2011" - no changes
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
}

DynamicBanListData = {
  # THESE LISTS SHOULD BE COMPLETE
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

  # INCOMPLETE
  "legacy" => {
    "Dig Through Time"   => {"start"=>"legal", "bfz"=>"banned"},
    "Black Vise"         => {"start"=>"banned", "bfz"=>"legal"},
    "Treasure Cruise"    => {"start"=>"legal", "frf"=> "banned"},
    "Worldgorger Dragon" => {"start"=>"banned", "frf"=> "legal"},
  },
  "vintage" => {
    "Chalice of the Void"  => {"start"=>"legal", "bfz"=>"restricted"},
    "Thirst for Knowledge" => {"start"=>"restricted", "bfz"=>"legal"},
    "Treasure Cruise"      => {"start"=>"legal", "frf"=> "restricted"},
    "Gifts Ungiven"        => {"start"=>"restricted", "frf"=> "legal"},
  },
}

class BanList
  def initialize
    @dates = Hash[SetReleaseDates.map{|key, date| [key, Date.parse(date)]}]
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

  private

  def parse_changes(changes)
    Hash[changes.map{|card, legalities|
      legalities = {"start" => legalities} if legalities.is_a?(String)
      legalities = legalities.map{|dat, leg| [@dates.fetch(dat), leg] }
      [card, legalities]
    }]
  end
end
