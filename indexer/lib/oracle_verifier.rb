class OracleVerifier
  def initialize
    @versions = {}
    @canonical = {}
  end

  def add(set_code, card_data)
    name = card_data["name"]
    @versions[name] ||= []
    @versions[name] << [set_code, card_data]
  end

  def report_variants!(card_name, key, variants)
    puts "Key #{key} of card #{card_name} is inconsistent between versions"
    variants.each do |variant, printings|
      puts "* #{variant.inspect} - #{printings.join(" ")}"
    end
    puts ""
  end

  def validate_and_report!(card_name, versions)
    # All versions are same, no reason to dig deeper
    if versions.map(&:last).uniq.size == 1
      @canonical[card_name] = versions[0][1]
    end
    # Something failed
    keys = versions.map(&:last).map(&:keys).inject(&:|)
    @canonical[card_name] = {}
    keys.each do |key|
      variants = {}
      versions.each do |set_code, version|
        variant = version[key]
        variants[variant] ||= []
        variants[variant] << set_code
      end
      canonical_variant = nil
      canonical_variant_source = nil

      if variants.size == 1
        # This key is fine
        canonical_variant = variants.keys[0]
      else
        # This key is broken
        # We need to fix it
        if key == "rulings"
          # That's low value fail, would be nice if they fixed it, but whatever
          canonical_variant = variants.keys.max_by{|v| v.to_s.size}
        elsif key == "supertypes"
          # Planeswalkers, promos didn't get updated yet
          if variants.keys.to_set == [nil, ["Legendary"]].to_set
            canonical_variant = ["Legendary"]
          end
        elsif key == "subtypes"
          if card_name == "Aesthir Glider"
            canonical_variant_source = "dom"
          end
        else
          case card_name
          # There were some huge changes, mtgjson update will take a while to sync them
          when "Ash Barrens", "Barrage Ogre", "Brion Stoutarm", "Chartooth Cougar", "Clifftop Retreat", "Darksteel Citadel", "Eladamri's Call", "Elvish Aberration", "Elvish Archdruid", "Elvish Mystic", "Foundry of the Consuls", "Gaea's Blessing", "Galvanic Blast", "Gilded Lotus", "Goblin Warchief", "Great Furnace", "Hinterland Harbor", "Imperial Recruiter", "Isolated Chapel", "Krosan Tusker", "Leaf Gilder", "Llanowar Elves", "Meandering River", "Myr Battlesphere", "Nature's Spiral", "Noble Templar", "Oran-Rief, the Vastwood", "Phyrexia's Core", "Pia and Kiran Nalaar", "Pyrite Spellbomb", "Ratcatcher", "Scuttling Doom Engine", "Seat of the Synod", "Serra Angel", "Shivan Reef", "Shoreline Ranger", "Shrapnel Blast", "Siege-Gang Commander", "Skirk Prospector", "Skizzik", "Stangg", "Sulfur Falls", "Summoner's Pact", "Swiftwater Cliffs", "Talara's Battalion", "Temple of Epiphany", "Timber Gorge", "Tranquil Thicket", "Treasure Mage", "Treetop Village", "Twisted Abomination", "Woodland Cemetery" 
            options = variants.values.flatten
            canonical_variant_source = ["dom", "ddu", "a25"].find{|x| options.include?(x)}
          when "Sultai Ascendancy"
            # BGU / UBG mana cost
            canonical_variant_source = "ktk"
          when "Mark of the Vampire", "Unknown Shores"
            canonical_variant_source = "xln"
          when "Juggernaut"
            canonical_variant_source = "m15"
          when "Fungusaur"
            canonical_variant_source = "8e"
          when "Bloodcrazed Neonate"
            canonical_variant_source = "isd"
          when "Uncontrollable Anger"
            canonical_variant_source = "cns"
          when "Fumiko the Lowblood"
            canonical_variant_source = "c15"
          when "Dauthi Slayer"
            canonical_variant_source = "tp"
          when "Goblin Rabblemaster"
            canonical_variant_source = "m15"
          when "Akoum Firebird"
            canonical_variant_source = "bfz"
          when "Flamewake Phoenix"
            canonical_variant_source = "frf"
          when "Nettling Imp"
            canonical_variant_source = "al"
          when "Steamflogger Boss"
            canonical_variant_source = "ust"
          when "Ashnod's Coupon"
            canonical_variant_source = "ug"
          when "Mise", "Circle of Protection: Art"
            canonical_variant_source = "uh"
          when "Strider Harness", "Traveler's Amulet"
            canonical_variant_source = "rix"
          when "Grafdigger's Cage"
            canonical_variant_source = "mm3"
          else
            # FAIL, report
          end
        end
      end
      if canonical_variant_source
        canonical_variant = versions.find{|k,v| k == canonical_variant_source}[1][key]
      end

      if canonical_variant
        @canonical[card_name][key] = canonical_variant
      else
        report_variants!(card_name, key, variants)
      end
    end
  end

  def canonical(card_name)
    return @canonical[card_name] if @canonical[card_name]
    raise "No canonical version for #{card_name}"
  end

  def verify!
    @versions.each do |card_name, versions|
      validate_and_report!(card_name, versions)
    end
  end
end
