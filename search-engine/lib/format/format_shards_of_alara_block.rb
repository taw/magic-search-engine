class FormatShardsOfAlaraBlock < Format
  def format_pretty_name
    "Shards of Alara Block"
  end

  def build_included_sets
    Set["ala", "cfx", "arb"]
  end
end
