class PatchMB1 < Patch
  def call
    assignment = sheet_assignments
    raise "Assignment is not unique" unless assignment.map(&:first).uniq.size == assignment.size
    assignment = assignment.to_h

    cards = cards_by_set["mb1"]
    raise "Card names don't match" unless cards.map{|c| c["name"] }.sort  == assignment.keys.sort

    cards.each do |card|
      name = card["name"]
      card["print_sheet"] = assignment[name]
    end
  end

  def data_root
    Pathname(__dir__).parent.parent.parent + "data"
  end

  def sheet_assignments
    sheets.flat_map do |code, file_name|
      path = (data_root + "print_sheets/mb1" + file_name)
      path.read.split(/\n| \/\/ /).map do |card_name|
        [card_name, code]
      end
    end
  end

  def sheets
    {
      "WA" => "white_a.txt",
      "WB" => "white_b.txt",
      "UA" => "blue_a.txt",
      "UB" => "blue_b.txt",
      "BA" => "black_a.txt",
      "BB" => "black_b.txt",
      "RA" => "red_a.txt",
      "RB" => "red_b.txt",
      "GA" => "green_a.txt",
      "GB" => "green_b.txt",
      "MC" => "multicolor.txt",
      "CL" => "colorless.txt",
      "OF" => "old_frame.txt",
      "R" => "rare.txt",
      # Foils are in FMB1 instead
      # Playtest cards are in CMB1
      # "F" => "foil.txt",
    }
  end
end
