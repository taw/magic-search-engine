class PatchPrintSheets < Patch
  def call
    sources.each_key do |set_code|
      add_print_sheet_information_for_set(set_code)
    end
  end

  private

  OVERRIDES = {
    "atq" => {
      "Mishra's Factory" => {
        "80a" => "C1", # "Mishra's Factory, spring"
        "80b" => "U1", # "Mishra's Factory, summer"
        "80c" => "U1", # "Mishra's Factory, autumn"
        "80d" => "U1", # "Mishra's Factory, winter"
      },
      "Strip Mine" => {
        "82a" => "C1", # "Strip Mine, no horizon"
        "82b" => "U1", # "Strip Mine, horizon, uneven stripe",
        "82c" => "U1", # "Strip Mine, small tower in forest"
        "82d" => "U1", # "Strip Mine, horizon, even stripe"
      },
      "Urza's Mine" => {
        "83a" => "C1", # "Urza's Mine, pulley"
        "83b" => "C1", # "Urza's Mine, mouth"
        "83c" => "C2", # "Urza's Mine, clawed sphere"
        "83d" => "C2", # "Urza's Mine, tower"
      },
      "Urza's Power Plant" => {
        "84a" => "C2", # "Urza's Power Plant, sphere"
        "84b" => "C1", # "Urza's Power Plant, columns"
        "84c" => "C2", # "Urza's Power Plant, bug"
        "84d" => "C1", # "Urza's Power Plant, rock in pot"
      },
      "Urza's Tower" => {
        "85a" => "C2", # "Urza's Tower, forest"
        "85b" => "C1", # "Urza's Tower, shore"
        "85c" => "C1", # "Urza's Tower, plains"
        "85d" => "C1", # "Urza's Tower, mountains"
      },
    },
  }

  def assign_print_sheet_information(cards, checklist)
    cards.zip(checklist).each do |card, checklist_entry|
      card["print_sheet"] = checklist_entry.last
    end
  end

  def add_print_sheet_information_for_card(set_code, name, cards, checklist)
    if checklist.map(&:last).uniq.size == 1
      assign_print_sheet_information(cards, checklist)
      return
    end

    overrides = cards.map{|c| OVERRIDES.dig(set_code, name, c["number"]) }

    # We have information about print sheets, but it's only human readable descriptions
    # Card order in mtgjson is not generally going to match card order on checklist documents
    if overrides.all?
      raise "Overrides incorrect" unless checklist.map(&:last).sort == overrides.sort
      cards.zip(overrides).each do |card, print_sheet|
        card["print_sheet"] = print_sheet
      end

      return
    end

    warn "Not yet sure how to deal with #{set_code} #{name} #{cards.size} #{checklist}"

    # At this point 27 cards which need special decisions
    #
    # If they're all by same artist, then we have no information which is which
    # (well, except maybe comment next to name)
    # so we assume they're in same order on checklist and as on Gatherer
    if checklist.map{|c| c[1]}.uniq.size == 1
      assign_print_sheet_information(cards, checklist)
      return
    end

    # And that's it! Somehow we never get here
    warn "Not yet sure how to deal with #{set_code} #{name} #{cards.size} #{checklist}"
  end

  def add_print_sheet_information_for_set(set_code)
    cards = cards_by_set[set_code]
    # Ignore printing error variants, but keep in ARN
    if set_code != "arn"
      cards = cards.select{|c| c["number"] !~ /†/ }
    end
    checklist = checklist_for(set_code)

    unless cards
      warn "Set #{set_code} does not exist"
      return
    end

    if cards.size != checklist.size
      warn "Can't connect print sheets for #{set_code} - #{cards.size} cards and #{checklist.size} checklist entries"
      return
    end

    checklist_by_name = Hash.new{|ht,k| ht[k] = []}

    checklist.each do |name, artist, info|
      canonical_name = if name == "Reveka, Wizard Savant"
        name
      else
        name
          .gsub(/Æ|AE/, "Ae")
          .gsub("Naf's Asp", "Nafs Asp")
          .gsub("Evil Eye of Orms-By-Gore", "Evil Eye of Orms-by-Gore")
          .gsub(/ \(v. ?\d\)\z/, "")
          .gsub(/ \([ab]\)\z/, "")
          .gsub(/\A(.*), The\z/) { "The #{$1}" }
          .gsub(/, .*\z/, "")
      end
      checklist_by_name[canonical_name] << [name, artist, info]
    end

    cards.group_by{|c| c["name"]}.each do |name, cards|
      unless checklist_by_name[name].size == cards.size
        warn "Incorrect checklist size #{set_code} #{name} #{cards.size} != #{checklist_by_name[name].size}"
        next
      end

      add_print_sheet_information_for_card(set_code, name, cards.sort_by{|c| c["multiverseid"]}, checklist_by_name[name])
    end
  end

  def sources
    {
      "all" => "Alliances_Checklist.txt",
      "atq" => "Antiquities_Checklist.txt",
      "arn" => "Arabian_Nights_Checklist.txt",
      "chr" => "Chronicles_Checklist.txt",
      "fem" => "Fallen_Empires_Checklist.txt",
      "hml" => "Homelands_Checklist.txt",
      "leg" => "Legends_Checklist.txt",
      "drk" => "The_Dark_Checklist.txt",
    }
  end

  def data_root
    Pathname(__dir__).parent.parent.parent + "data"
  end

  # There's some incorrect information on official checklists
  # http://www.magiclibrarities.net/forum/viewtopic.php?t=9906 for correction
  #
  # Homelands: Joven: U1 -> C1
  # Homelands: Chandler: U1 -> C1
  # Alliances: Gorilla Shaman (v. 2): U2 -> U3
  # Alliances: Kjeldoran Escort (v. 1): C1 -> C2
  # Legends: Unholy Citadel: U2 -> U1
  # Legends: Seafarer's Quay: U2 -> U1
  def checklist_for(set_code)
    path = data_root + "print_sheets/#{sources.fetch(set_code)}"
    path
      .readlines
      .map(&:chomp)
      .map(&:strip)
      .map{|line| line.gsub("Jeff  A. Menges", "Jeff A. Menges") }
      .map{|line| line.gsub(/\AChandler\s+Douglas Shuler\s+\KU1/, "C1")}
      .map{|line| line.gsub(/\AJoven\s+Douglas Shuler\s+\KU1/, "C1")}
      .map{|line| line.gsub(/\AGorilla Shaman \(v\. 2\)\s+Anthony Waters\s+\KU2/, "U3") }
      .map{|line| line.gsub(/\AKjeldoran Escort \(v\. 1\)\s+Bryon Wackwitz\s+\KC1/, "C2") }
      .map{|line| line.gsub(/\AUnholy Citadel\s+Mark Poole\s+\KU2/, "U1") }
      .map{|line| line.gsub(/\ASeafarer's Quay\s+Tom Wänerstrand\s+\KU2/, "U1") }
      .grep(/ {2,}/)
      .map{|line| line.split(/ {2,}/, 3) }
      .each{|name, artist, info|
        # Strip reprint information from chronicles
        info.sub!(/\A[A-Z]\d+\K  ..\z/, "")
      }
  end
end
