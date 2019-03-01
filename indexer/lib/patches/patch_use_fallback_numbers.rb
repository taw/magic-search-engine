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
    raise "Requesting fallback numbers for #{set_code} but we don't have them" unless path.exist?
    path.readlines.map{|line|
      number, name, multiverseid = line.chomp.split("\t", 3)
      [number, name.downcase, multiverseid && multiverseid.to_i]
    }
  end

  def use_fallback_numbers(set_code)
    cards = cards_by_set[set_code]

    if cards.all?{|c| c["multiverseid"] }
      use_fallback_numbers_gatherer(set_code)
    else
      use_fallback_numbers_nongatherer(set_code)
    end
  end

  def use_fallback_numbers_gatherer(set_code)
    cards = cards_by_set[set_code]
    fallback_numbers = get_fallback_numbers(set_code)
    raise unless fallback_numbers.all?{|_,_,multiverseid| multiverseid}

    map = fallback_numbers.map{|id, name, multiverseid| [multiverseid, id]}.to_h
    cards.each do |card|
      card["number"] = map.fetch(card["multiverseid"])
    end
  end

  # ced / cei
  def use_fallback_numbers_nongatherer(set_code)
    cards = cards_by_set[set_code]
    fallback_numbers = get_fallback_numbers(set_code)
      .group_by{|_, name, _| name}
      .transform_values{|rows|
        rows.map(&:first).sort_by{|n| [n.to_i, n] }
      }
    cards.each do |card|
      name = card["name"]
      card["number"] = fallback_numbers[name.downcase].shift
    end
  end
end
