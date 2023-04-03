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
          assignment[name] = sheet
        elsif parts.size == 3
          name, number, sheet = parts
          assignment[[name, number]] = sheet
        else
          raise "Invalid line: #{line}"
        end
      end

      cards_by_set[set_code].each do |card|
        sheet = assignment.delete([card["name"], card["number"]]) || assignment.delete(card["name"])
        next unless sheet
        card["print_sheet"] = sheet
      end

      unless assignment.empty?
        raise "Leftover print sheet data for #{set_code}"
      end
    end
  end

  def data_root
    Pathname(__dir__).parent.parent.parent + "data/print_sheets_new"
  end
end
