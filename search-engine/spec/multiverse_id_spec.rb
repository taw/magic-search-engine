describe "multiverse ids" do
  include_context "db"

  # Old multipart cards have separate ID
  # New multipart cards have one ID
  # At some point mtgjson started ignoring separate IDs
  it "there are no duplicates" do
    # It's somewhat questionable when it comes to multipart
    # They have multiple ids
    by_id = db.printings.select(&:multiverseid).group_by(&:multiverseid).select{|k,v| v.size > 1}
    by_id.each do |id, cards|
      main_fronts = cards.map{|c| PhysicalCard.for(c).main_front}.uniq
      if main_fronts.size == 1
        # OK
      elsif cards[0].name == "Nalathni Dragon"
        # Known issue, ignore for now
      elsif cards[0].name == "Spined Wurm"
        # Known issue, ignore for now - PMEI / S00
      else
        cards.size.should eq(1), "#{id} #{cards}"
      end
    end
  end

  it "each set is all with or all without multiveresids" do
    db.sets.each do |set_code, set|
      # These are gatherer sets to which mtgjson adds some extra cards
      case set_code
      when "aer", "kld", "mir", "ody", "5ed", "shm", "10e", "soi", "atq", "drk", "unh", "m20", "4ed"
        # It's a very specific check as we want to do the same check in PatchExcludeFromBoosters
        set.printings.group_by{|x| [!(x.number =~ /†|★/), !!x.multiverseid]}.keys.should match_array([
          [true, true], [false, false]
        ]), "Set #{set_code} should have all non-gatherer cards marked with † or ★"
      # Known issues, ignore for now
      when "ppre" # Weird "Promo set for Gatherer"
      when "pmei"
      when "s00"
      when "war" # Japanese promos
      when "med" # reported mtgjson bug
      when "phop" # fake set with stuff coming from 2 sources
      when "pmoa" # vanguard weirdness
      when "sld" # set keeps getting updated
      when "cmb1"
      when "eld"
        # Something's really messed up here, possibly related to ELD vs CELD
      when "thb"
        # Not yet
      else
        set.printings.group_by{|c| !!c.multiverseid}.size.should eq(1), "Set #{set_code} has cards with and without multiverseid"
      end
    end
  end
end
