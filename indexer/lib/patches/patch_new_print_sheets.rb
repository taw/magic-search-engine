class PatchNewPrintSheets < Patch
  def call
    each_set do |set|
      set_code = set["code"]
      path = data_root + "#{set_code}.txt"
      next unless path.exist?
      lines = path.read.gsub(/\s*#.*/, "").split("\n").grep(/\S/)

      assignment = {}
      lines.each do |line|
        parts = line.split(/ {2,}/, 3)
        if parts.size == 2
          name, sheet = parts
          name = name.split("//").first.strip # Just take the first part
          assignment[name] = sheet
        elsif parts.size == 3
          name, number, sheet = parts
          name = name.split("//").first.strip # Just take the first part
          assignment[[name, number]] = sheet
        else
          raise "Invalid line: #{line}"
        end
      end

      cards_by_set[set_code].each do |card|
        sheet = assignment.delete([card["name"], card["number"]]) || assignment.delete(card["name"])
        next unless sheet
        if card.key?("print_sheet")
          card["print_sheet"] = card["print_sheet"] + " " + sheet
        else
          card["print_sheet"] = sheet
        end
      end

      unless assignment.empty?
        raise "Leftover print sheet data for #{set_code}: #{assignment.inspect}"
      end
    end
  end

  def data_root
    Pathname(__dir__).parent.parent.parent + "data/print_sheets_new"
  end
end
