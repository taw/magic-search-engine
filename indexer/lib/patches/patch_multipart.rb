class PatchMultipart < Patch
  def call
    each_printing do |card|
      next unless card["names"]
      other_names = card["names"] - [card["name"]]
      card["others"] = other_names.map{|other_name|
        other_card = resolve_other(card, other_name)
        other_card && other_card["number"]
      }
    end
  end

  def special_data
    {
      "pbro" => {
        ["Mishra, Lost to Phyrexia", "163bp"] => {"Mishra, Claimed by Gix" => "216p", "Phyrexian Dragon Engine" => "163ap"},
        ["Mishra, Lost to Phyrexia", "163bs"] => {"Mishra, Claimed by Gix" => "216s", "Phyrexian Dragon Engine" => "163as"},
        ["Urza, Planeswalker", "238bp"] => {"The Mightstone and Weakstone" => "238ap", "Urza, Lord Protector" => "225p"},
        ["Urza, Planeswalker", "238bs"] => {"The Mightstone and Weakstone" => "238as", "Urza, Lord Protector" => "225s"},
        ["Titania, Gaea Incarnate", "256bp"] => {"Titania, Voice of Gaea" => "193p", "Argoth, Sanctum of Nature" => "256ap"},
        ["Titania, Gaea Incarnate", "256bs"] => {"Titania, Voice of Gaea" => "193s", "Argoth, Sanctum of Nature" => "256as"},
      },
      "sld" => {
        ["Brisela, Voice of Nightmares", "1336b"] => {"Gisela, the Broken Blade" => "1335", "Bruna, the Fading Light" => "1336"},
        ["Brisela, Voice of Nightmares", "1388b"] => {"Gisela, the Broken Blade" => "1387", "Bruna, the Fading Light" => "1388"},
      },
      "fin" => {
        ["Ragnarok, Divine Deliverance", "99b"] => {"Vanille, Cheerful l'Cie" => "211", "Fang, Fearless l'Cie" => "99"},
        ["Ragnarok, Divine Deliverance", "381b"] => {"Vanille, Cheerful l'Cie" => "392", "Fang, Fearless l'Cie" => "381"},
        ["Ragnarok, Divine Deliverance", "446b"] => {"Vanille, Cheerful l'Cie" => "475", "Fang, Fearless l'Cie" => "446"},
        ["Ragnarok, Divine Deliverance", "526b"] => {"Vanille, Cheerful l'Cie" => "537", "Fang, Fearless l'Cie" => "526"},
      },
    }
  end

  def special
    unless @special
      @special = {}
      special_data.each do |set_code, set_data|
        @special[set_code] ||= {}
        set_data.each do |melded, parts|
          @special[set_code][melded] = parts
          parts.each do |k, v|
            @special[set_code][[k, v]] = [melded].to_h
          end
        end
      end
    end
    @special
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

    other_number = special.dig(set_code, [card_name, number], other_name)
    if other_number
      other = from_same_set.find{|c| c["number"] == other_number }
      return other if other
    end
    # This will mess up the index, but it's easier to fix things if I have full list of failing cases
    warn "Can't resolve match for #{other_name} for #{card_name} [#{set_code}/#{number}]. Candidates are #{from_same_set.map{|c| c["number"]}.join(", ")}"
    nil
  end
end
