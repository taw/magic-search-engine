class FormatShardsOfAlaraBlock < Format
  def format_pretty_name
    "Shards of Alara Block"
  end

  def format_start_date
    "2008-10-03"
  end

  def build_included_sets
    Set["ala", "con", "arb"]
  end
end
