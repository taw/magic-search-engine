class FormatShardsOfAlaraBlock < Format
  def format_name
    "shards of alara block"
  end

  def format_sets
    Set["ala", "cfx", "arb"]
  end
end
