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

    # And then there's meld cards in PBRO with a lot of meld cards
    # This isn't a good format as everything is listed twice, but it's only a few cards
    special = {
      "pbro" => {
        # Mishra
        ["Phyrexian Dragon Engine", "163ap"] => {"Mishra, Lost to Phyrexia" => "163bp"},
        ["Phyrexian Dragon Engine", "163as"] => {"Mishra, Lost to Phyrexia" => "163bs"},
        ["Mishra, Lost to Phyrexia", "163bp"] => {"Mishra, Claimed by Gix" => "216p", "Phyrexian Dragon Engine" => "163ap"},
        ["Mishra, Lost to Phyrexia", "163bs"] => {"Mishra, Claimed by Gix" => "216s", "Phyrexian Dragon Engine" => "163as"},
        ["Mishra, Claimed by Gix", "216p"] => {"Mishra, Lost to Phyrexia" => "163bp"},
        ["Mishra, Claimed by Gix", "216s"] => {"Mishra, Lost to Phyrexia" => "163bs"},
        # Urza
        ["Urza, Lord Protector", "225p"] => {"Urza, Planeswalker" => "238bp"},
        ["Urza, Lord Protector", "225s"] => {"Urza, Planeswalker" => "238bs"},
        ["The Mightstone and Weakstone", "238ap"] => {"Urza, Planeswalker" => "238bp"},
        ["The Mightstone and Weakstone", "238as"] => {"Urza, Planeswalker" => "238bs"},
        ["Urza, Planeswalker", "238bp"] => {"The Mightstone and Weakstone" => "238ap", "Urza, Lord Protector" => "225p"},
        ["Urza, Planeswalker", "238bs"] => {"The Mightstone and Weakstone" => "238as", "Urza, Lord Protector" => "225s"},
        # Titania
        ["Titania, Voice of Gaea", "193p"] => {"Titania, Gaea Incarnate" => "256bp"},
        ["Titania, Voice of Gaea", "193s"] => {"Titania, Gaea Incarnate" => "256bs"},
        ["Argoth, Sanctum of Nature", "256ap"] => {"Titania, Gaea Incarnate" => "256bp"},
        ["Argoth, Sanctum of Nature", "256as"] => {"Titania, Gaea Incarnate" => "256bs"},
        ["Titania, Gaea Incarnate", "256bp"] => {"Titania, Voice of Gaea" => "193p", "Argoth, Sanctum of Nature" => "256ap"},
        ["Titania, Gaea Incarnate", "256bs"] => {"Titania, Voice of Gaea" => "193s", "Argoth, Sanctum of Nature" => "256as"},
      },
      "sld" => {
        # Brisela
        ["Gisela, the Broken Blade", "1335"] => {"Brisela, Voice of Nightmares" => "1336b"},
        ["Bruna, the Fading Light", "1336"] => {"Brisela, Voice of Nightmares" => "1336b"},
        ["Brisela, Voice of Nightmares", "1336b"] => {"Gisela, the Broken Blade" => "1335", "Bruna, the Fading Light" => "1336"},
        ["Gisela, the Broken Blade", "1387"] => {"Brisela, Voice of Nightmares" => "1388b"},
        ["Bruna, the Fading Light", "1388"] => {"Brisela, Voice of Nightmares" => "1388b"},
        ["Brisela, Voice of Nightmares", "1388b"] => {"Gisela, the Broken Blade" => "1387", "Bruna, the Fading Light" => "1388"},
      }
    }
    other_number = special.dig(set_code, [card_name, number], other_name)
    if other_number
      other = from_same_set.find{|c| c["number"] == other_number }
      return other if other
    end
    raise "Can't resolve match for #{other_name} for #{card_name} [#{set_code}/#{number}]. Candidates are #{from_same_set.map{|c| c["number"]}.join(", ")}"
  end
end
