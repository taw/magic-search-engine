class PatchNewPrintSheets < Patch
  def call
    each_set do |set|
      set_code = set["code"]
      path = data_root + "#{set_code}.txt"
      next unless path.exist?
      lines = path.read.gsub(/\s*#.*/, "").split("\n").grep(/\S/)

      assignment =  lines.map{|line|
        name, number, sheet = line.split(/ {2,}/, 3); [[name, number], sheet]
      }.to_h

      cards_by_set[set_code].each do |card|
        key = [card["name"], card["number"]]
        sheet = assignment.delete(key)
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
