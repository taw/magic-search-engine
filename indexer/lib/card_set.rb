MagicBlocks = [
  ["ia", "Ice Age", "ia", "ai", "cs"],
  # ["shm", "Shadowmoor", "shm", "eve"], # Also included in Lorwyn
  ["mr", "Mirage", "mr", "vi", "wl"],
  ["tp", "Tempest", "tp", "sh", "ex"],
  ["us", "Urza's Saga", "us", "ul", "ud"],
  ["mm", "Mercadian Masques", "mm", "ne", "pr"],
  ["in", "Invasion", "in", "ps", "ap"],
  ["od", "Odyssey", "od", "tr", "ju"],
  ["on", "Onslaught", "on", "le", "sc"],
  ["mi", "Mirrodin", "mi", "ds", "5dn"],
  ["chk", "Champions of Kamigawa", "chk", "bok", "sok"],
  ["rav", "Ravnica", "rav", "gp", "di"],
  ["ts", "Time Spiral", "ts", "tsts", "pc", "fut"],
  ["lw", "Lorwyn", "lw", "mt", "shm", "eve"],
  ["ala", "Shards of Alara", "ala", "cfx", "arb"],
  ["zen", "Zendikar", "zen", "wwk", "roe"],
  ["som", "Scars of Mirrodin", "som", "mbs", "nph"],
  ["isd", "Innistrad", "isd", "dka", "avr"],
  ["rtr", "Return to Ravnica", "rtr", "gtc", "dgm"],
  ["ths", "Theros", "ths", "bng", "jou"],
  ["ktk", "Khans of Tarkir", "ktk", "frf", "dtk"],
  ["bfz", "Battle for Zendikar", "bfz", "ogw"],
  ["soi", "Shadows over Innistrad", "soi", "emn"],
  ["kld", "Kaladesh", "kld", "aer"],
  ["akh", "Amonkhet", "akh", "hou"],
  ["xln", "Ixalan", "xln"],
]

class Indexer
  class CardSet
    attr_reader :set_code, :set_data
    def initialize(set_code, set_data)
      @set_code = set_code
      @set_data = set_data
      @block_code, @block_name = MagicBlocks.find{|c,n,*xx| xx.include?(set_code)} || []
    end

    def to_json
      {
        "code" => @set_code,
        "name" => @set_data["name"],
        "gatherer_code" => @set_data["code"],
        "block_code" => @block_code,
        "block_name" => @block_name,
        "border" => @set_data["border"],
        "online_only" => @set_data["onlineOnly"],
        "release_date" => Indexer.format_release_date(@set_data["releaseDate"]),
        "type" => @set_data["type"],
      }.compact
    end

    # They really only have two goals:
    # * be unique
    # * allow linking to magiccards.info for debugging
    #
    # For uniqueness sake we could just allocate them ourselves easily
    # But to make them compatible instead we use mci's numbers
    #
    # For cards with multiple printings it's not obvious how to get them arranged so pics match,
    # but it's not a huge deal
    #
    # By the way ordering by multiverseid would probably be more sensible
    # (alpha starts with Ankh of Mishra, not Animate Dead), but compatibilty etc.

    def ensure_set_has_card_numbers!
      cards = @set_data["cards"]
      numbers = cards.map{|c| c["number"]}

      use_mci_numbers! if numbers.compact.empty?

      case set_code
      when "van"
        set_data["cards"].sort_by{|c| c["multiverseid"]}.each_with_index{|c,i| c["number"] = "#{i+1}"}
      when "pch", "arc", "pc2", "pca", "e01"
        set_data["cards"].each do |card|
          unless (card["types"] & ["Plane", "Phenomenon", "Scheme"]).empty?
            card["number"] = (1000 + card["number"].to_i).to_s
          end
        end
      when "bfz", "ogw"
        # No idea if this is correct
        basic_land_cards = set_data["cards"].select{|c| (c["supertypes"]||[]) .include?("Basic") }
        basic_land_cards = basic_land_cards.sort_by{|c| [c["number"], c["multiverseid"]]}
        basic_land_cards.each_slice(2) do |a,b|
          raise unless a["number"] == b["number"]
          b["number"] += "A"
        end
      when "rqs", "me4"
        # Just brute force, investigate later wtf?
        set_data["cards"].sort_by{|c| c["multiverseid"]}.each_with_index{|c,i| c["number"] = "#{i+1}"}
      when "st2k"
        # Just brute force, investigate later wtf?
        set_data["cards"].each_with_index{|c,i| c["number"] = "#{i+1}"}
      when "ust"
        # No idea if this is correct
        cards_with_variants = %W[3 12 41 49 54 67 82 98 103 113 145 147 165]
        variant_counter = {}
        set_data["cards"].each do |card_data|
          number = card_data["number"]
          next unless cards_with_variants.include?(number)
          variant_counter[number] = variant_counter[number] ? variant_counter[number].next : "A"
          card_data["number"] = number + variant_counter[number]
        end
      end

      numbers = cards.map{|c| c["number"]}
      if numbers.compact.size == 0
        warn "Set #{set_code} #{set_data["name"]} has NO numbers"
      elsif numbers.compact.size != numbers.size
        warn "Set #{set_code} #{set_data["name"]} has cards without numbers"
      end
      if numbers.compact.size != numbers.compact.uniq.size
        # This breaks the frontend, so it needs to be hard exception
        duplicates = numbers.compact.group_by(&:itself).transform_values(&:count).select{|k,v| v > 1}
        raise "Set #{set_code} #{set_data["name"]} has DUPLICATE numbers: #{duplicates.inspect}"
      end
    end

    # Assume that if two Forests are 100 and 101
    # then Forest with lower multiverse id gets 100
    # No idea if that's correct
    def use_mci_numbers!
      path = Indexer::ROOT + "collector_numbers/#{set_code}.txt"
      return unless path.exist?
      mci_numbers = path.readlines.map{|line|
        number, name = line.chomp.split("\t", 2)
        [number, name.downcase]
      }.group_by(&:last).transform_values{|x| x.map(&:first)}

      cards = set_data["cards"]

      if set_code == "ced" or set_code == "cedi"
        # Not on Gatherer
        cards.each do |card|
          name = card["name"]
          card["number"] = mci_numbers[name.downcase].shift
        end
      else
        mvids = cards.map{|c| [c["name"], c["multiverseid"]]}.group_by(&:first).transform_values{|x| x.map(&:last).sort}
        cards.each do |card|
          name = card["name"]
          rel_idx = mvids[name].index(card["multiverseid"])
          raise unless mci_numbers[name.downcase]
          card["number"] = mci_numbers[name.downcase][rel_idx]
        end
      end
    end
  end
end
