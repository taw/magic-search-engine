class PatchMultipart < Patch
  def call
    each_printing do |card|
      next unless card["names"]
      other_names = card["names"] - [card["name"]]
      card["others"] = other_names.map{|other_name| resolve_other(card, other_name)["number"] }
    end
  end

  def resolve_other(card, other_name)
    card_name = card["name"]
    set_code = card["set_code"]
    number = card["number"]
    from_same_set = @cards[other_name].select{|c| c["set_code"] == set_code }

    # No ambiguity
    raise "No possible matches for #{other_name} found for #{card_name} [#{set_code}/#{number}]" if from_same_set.empty?
    return from_same_set[0] if from_same_set.size == 1

    # Obvious matches like 10a/10b and 330a/330b
    matches_by_number = from_same_set.select{|c| c["number"].sub(/[ab]\z/, "") == number.sub(/[ab]\z/, "")}
    return matches_by_number[0] if matches_by_number.size == 1

    # And then there's meld cards in PBRO...
    raise "Can't resolve match for #{other_name} for #{card_name} [#{set_code}/#{number}]"
  end
end
