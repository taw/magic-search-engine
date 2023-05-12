class IndexSerializer
  def initialize(sets, cards, products)
    @sets = sets
    @cards = cards
    @products = products.group_by{|x| x["set_code"]}
  end

  def to_s
    sets_h = @sets.map{|s| [s["code"], index_set(s)]}.to_h
    set_order = sets_h.keys.each_with_index.to_h
    index_data = {
      "sets" => sets_h,
      "cards" => @cards.map{|name, card_data|
        [name, index_card(card_data, set_order)]
      }.sort.to_h,
    }
    # Keep set index order as is, normalize eveything else
    index_data["cards"] = json_normalize(index_data["cards"])
    index_data["sets"].each do |set_code, set|
      index_data["sets"][set_code] = set
    end
    index_data.to_json
  end

  private

  def json_normalize(data)
    if data.is_a?(Array)
      data.map do |elem|
        json_normalize(elem)
      end
    elsif data.is_a?(Hash)
      Hash[data.map{|k,v|
        [k, json_normalize(v)]
      }.sort]
    else
      data
    end
  end

  def index_product(product)
    product.slice(
      "name",
    )
  end

  def index_set(set)
    set.slice(
      "alternative_block_code",
      "alternative_code",
      "base_set_size",
      "block_code",
      "block_name",
      "border",
      "code",
      "custom",
      "foiling",
      "funny",
      "has_boosters",
      "in_other_boosters",
      "name",
      "online_only",
      "release_date",
      "subsets",
      "types",
    ).merge(
      "products" => (@products[set["code"]] || []).map{|x| index_product(x)}
    ).compact
  end

  def index_card(card, set_order)
    common_card_data = []
    printing_data = []
    card.each do |printing|
      common_card_data << printing.slice(
        "brawler",
        "ci",
        "cmc",
        "colors",
        "commander",
        "defense",
        "display_power",
        "display_toughness",
        "foreign_names",
        "funny",
        "hand", # vanguard
        "hide_mana_cost",
        "is_partner",
        "keywords",
        "layout",
        "life", # vanguard
        "loyalty",
        "manaCost",
        "name",
        "names",
        "power",
        "related",
        "reserved",
        "rulings",
        "secondary",
        "subtypes",
        "supertypes",
        "text",
        "toughness",
        "types",
      ).compact

      printing_data << [
        printing["set_code"],
        printing.slice(
          "arena",
          "artist",
          "attraction_lights",
          "border",
          "digital",
          "etched",
          "exclude_from_boosters",
          "flavor_name",
          "flavor",
          "foiling",
          "frame_effects",
          "frame",
          "fullart",
          "language",
          "mtgo",
          "multiverseid",
          "nontournament",
          "number",
          "others",
          "oversized",
          "paper",
          "partner",
          "print_sheet",
          "promo_types",
          "rarity",
          "release_date",
          "shandalar",
          "signature",
          "spotlight",
          "stamp",
          "subsets",
          "textless",
          "timeshifted",
          "variant_foreign",
          "variant_misprint",
          "watermark",
          "xmage",
        ).compact,
      ]
    end

    result = common_card_data[0]
    name = result["name"]
    # Make sure it's reconciled at this point
    # This should be hard error once we're done
    report_if_inconsistent(name, common_card_data, card)

    # Output in canonical form, to minimize diffs between mtgjson updates
    result["printings"] = printing_data.sort_by{|sc,d|
      [set_order.fetch(sc), d["number"], d["multiverseid"] || 0]
    }
    result
  end

  def report_if_inconsistent(name, common_card_data, card)
    return if common_card_data.uniq.size == 1
    keys = common_card_data.map(&:keys).inject(&:|)
    inconsistent_keys = keys.select{|key| common_card_data.map{|ccd| ccd[key]}.uniq.size > 1 }
    warn "Data for card #{name} inconsistent on #{inconsistent_keys.join(", ")}"
    inconsistent_keys.each do |key|
      warn "* #{key}: #{card.map{|c| [c["set_code"], c[key]]}.inspect}"
    end
  end
end
