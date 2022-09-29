class PatchUnstable < Patch
  def call
    hard_variants.each do |name|
      @cards[name].dup.each do |card|
        variant = card["number"][/[a-z]/]
        rename_printing card, "#{name} (#{variant})"
      end
    end

    # Excludes basics, contraptions, and Steamflogger Boss
    ust_cards = @cards
      .values
      .flatten
      .select{|c| c["set_code"] == "ust" }
      .select{|c| c["border"] == "silver"  }

    ust_cards.group_by{|c| c["number"].to_i}.values.each do |group|
      key = [group.size, group[0]["rarity"]]
      group.each do |card|
        card["print_sheet"] = case key
        when [1, "common"]
          "C4"
        when [4, "common"]
          "C1"
        when [5, "common"]
          "C1"
        when [1, "uncommon"]
          "U6"
        when [6, "uncommon"]
          "U1"
        when [1, "rare"]
          "R6"
        when [1, "mythic"]
          "R3"
        when [6, "rare"]
          "R1"
        else
          raise "Bad Unstable variant count: #{key.inspect}: #{group.inspect}"
        end
      end
    end
  end

  def hard_variants
    [
      "Everythingamajig",
      "Garbage Elemental",
      "Ineffable Blessing",
      "Knight of the Kitchen Sink",
      "Sly Spy",
      "Very Cryptic Command",
    ]
  end
end
