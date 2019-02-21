class PatchUseFallbackNumbers < Patch
  def call
    each_set do |set|
      set_code = set["code"]
      use_fallback_numbers(set_code) if cards_by_set[set_code].none?{|c| c["number"]}
    end
  end

  private

  def get_fallback_numbers(set_code)
    path = Indexer::ROOT + "collector_numbers/#{set_code}.txt"
    raise "Requesting MCI numbers for #{set_code} but we don't have them" unless path.exist?
    path.readlines.map{|line|
      number, name, multiverseid = line.chomp.split("\t", 3)
      [number, name.downcase]
    }.group_by(&:last).transform_values{|x| x.map(&:first)}
  end

  # Assume that if two Forests are 100 and 101
  # then Forest with lower multiverse id gets 100
  # No idea if that's correct
  def use_fallback_numbers(set_code)
    mci_numbers = get_fallback_numbers(set_code)
    cards = cards_by_set[set_code]

    if set_code == "ced" or set_code == "cei"
      # Not on Gatherer
      cards.each do |card|
        name = card["name"]
        card["number"] = mci_numbers[name.downcase].shift
      end
    else
      mvids = cards.map{|c| [c["name"], c["multiverseid"]]}
        .group_by(&:first)
        .transform_values{|x| x.map(&:last).sort}
      cards.each do |card|
        name = card["name"]
        rel_idx = mvids[name].index(card["multiverseid"])
        raise unless mci_numbers[name.downcase]
        card["number"] = mci_numbers[name.downcase][rel_idx]
      end
    end
  end
end
