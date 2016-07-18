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
  ["soi", "Shadows over Innistrad", "soi"],
]

class Indexer
  class CardSet
    def initialize(set_code, set_data)
      @set_code = set_code
      @set_data = set_data
      @block_code, @block_name = MagicBlocks.find{|c,n,*xx| xx.include?(set_code)} || []
      if @set_code == "w16"
        @set_data["releaseDate"] ||= "2016-03-30"
      end
    end

    def to_json
      {
        "code" => @set_code,
        "name" => @set_data["name"],
        "gatherer_code" => @set_data["code"],
        "block_code" => @block_code,
        "block_name" => @block_name,
        "border" => @set_data["border"],
        "release_date" => Indexer.format_release_date(@set_data["releaseDate"]),
        "type" => @set_data["type"],
      }.compact
    end
  end
end
