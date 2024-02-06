class PatchMultiPrintSheets < Patch
  def call
    data_root.children("*.txt").each do |path|
      sheet = path.basename(".txt").to_s
      assignment = {}

      path.readlines.each do |orig_line|
        line = orig_line.chomp.sub(/\s*#.*/, "")
        next unless line =~ /\S/
        parts = line.split(/ {2,}/, 2)
        raise "Incorrect line in #{path}: #{orig_line}" unless parts.size == 2
        name = parts[0]
        name = name.split("//").first.strip # Just take the first part
        raise "Incorrect <set code>:<number> in #{path}: #{orig_line}" unless parts[1] =~ /\A(.*):(.*)\z/
        set_code = $1.downcase
        number = $2
        assignment[[name, set_code, number]] = true
      end

      each_printing do |card|
        key = [card["name"], card["set_code"], card["number"]]
        next unless assignment[key]

        assignment.delete(key)

        if card.key?("print_sheet")
          card["print_sheet"] = card["print_sheet"] + " " + sheet
        else
          card["print_sheet"] = sheet
        end
      end

      unless assignment.empty?
        raise "Leftover print sheet data for #{sheet}: #{assignment.inspect}"
      end
    end
  end

  def data_root
    Pathname(__dir__).parent.parent.parent + "data/print_sheets_multi"
  end
end
