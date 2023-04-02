class PatchABUR < Patch
  def call
    ["lea", "leb", "2ed", "3ed"].each do |set_code|
      assignment = sheet_assignments[set_code]
      cards = cards_by_set[set_code]

      cards.each do |card|
        name = card["name"]
        number = card["number"]
        rarity = card["rarity"]

        case name
        when "Plains", "Island", "Swamp", "Mountain", "Forest"
          counts = assignment[number]
          card["print_sheet"] = ["C", "U", "R"].map{|s| "#{s}#{counts[s]}" if counts[s] > 0 }.compact.join(" ")
          next
        end

        # No basic rarity at this point
        case rarity
        when "common"
          card["print_sheet"] = "C1"
        when "uncommon"
          card["print_sheet"] = "U1"
        when "rare"
          card["print_sheet"] = "R1"
        else
          raise "Unknown rarity: #{rarity}"
        end
      end
    end
  end

  def sheet_assignments
    unless @sheet_assignments
      sheet_assignments = {}
      sheets.each do |file_name, set_code, sheet_name|
        sheet_assignments[set_code] ||= {}
        path = (data_root + "print_sheets/abur" + file_name)
        cards = path.readlines.map(&:chomp).map{|c| c.split("/")[1] }
        cards.each do |c|
          sheet_assignments[set_code][c] ||= Hash.new(0)
          sheet_assignments[set_code][c][sheet_name] += 1
        end
      end
    end
    sheet_assignments
  end

  def data_root
    Pathname(__dir__).parent.parent.parent + "data"
  end

  # Most sheets are frow http://www.lethe.xyz/mtg/collation/lea.html
  #
  # The uncommon and rare sheets for Alpha are not known exactly,
  # but the evidence from pack openings is consistent with the popular theory
  # that they are basically the same as the Beta sheets. The most notable difference
  # is the absence of Circle of Protection: Black and Volcanic Island that were added for Beta.
  # Beta also added a third art variation for each basic land, but it appears that positions
  # were not changed — only some of the existing lands were changed to the new art.
  # There is, however, an exception to this on the common sheet where analysis of pack
  # openings has revealed that the land to the left of Circle of Protection: Black is also different.
  #
  # I assume both variants of each Alpha land are equally common
  # Except rare sheet has 5 Islands, so I arbitrarily assume first is twice as likely

  def sheets
    [
      ["lea-c.txt", "lea", "C"],
      ["lea-u.txt", "lea", "U"], # approximation for just basics, as real is unknown
      ["lea-r.txt", "lea", "R"], # approximation for just basics, as real is unknown

      ["leb-c.txt", "leb", "C"],
      ["leb-u.txt", "leb", "U"],
      ["leb-r.txt", "leb", "R"],

      ["2ed-c.txt", "2ed", "C"],
      ["2ed-u.txt", "2ed", "U"],
      ["2ed-r.txt", "2ed", "R"],

      ["3ed-c.txt", "3ed", "C"],
      ["3ed-u.txt", "3ed", "U"],
    ]
  end
end
