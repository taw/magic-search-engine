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
      common_card_data << {
        "al" => printing["alchemy"],
        "br" => printing["brawler"],
        "c" => printing["colors"],
        "ci" => printing["ci"],
        "cm" => printing["commander"],
        "df" => printing["defense"],
        "dl" => printing["decklimit"],
        "dp" => printing["display_power"],
        "dt" => printing["display_toughness"],
        "f" => printing["foreign_names"],
        "fu" => printing["funny"],
        "ha" => printing["has_alchemy"],
        "hd" => printing["hand"], # vanguard
        "hm" => printing["hide_mana_cost"],
        "ip" => printing["is_partner"],
        "is" => printing["in_spellbook"],
        "k" => printing["keywords"],
        "l" => printing["layout"],
        "lf" => printing["life"], # vanguard
        "ly" => printing["loyalty"],
        "m" => printing["mana"],
        "n" => printing["name"],
        "ns" => printing["names"],
        "o" => printing["text"],
        "pw" => printing["power"],
        "r" => printing["rulings"],
        "rl" => printing["related"],
        "rs" => printing["reserved"],
        "s" => printing["secondary"],
        "sb" => printing["spellbook"],
        "sd" => printing["specialized"],
        "ss" => printing["specializes"],
        "t" => printing["types"],
        "tb" => printing["subtypes"],
        "to" => printing["toughness"],
        "tp" => printing["supertypes"],
        "v" => printing["cmc"],
      }.compact

      rarity = printing["rarity"]
      rarity_code = %W[basic common uncommon rare mythic special].index(rarity) or raise "Unknown rarity #{rarity}"

      printing_data << [
        printing["set_code"],
        {
          "a" => printing["artist"],
          "al" => printing["attraction_lights"],
          "ar" => printing["arena"],
          "b" => printing["border"],
          "d" => printing["release_date"],
          "e" => printing["etched"],
          "f" => printing["frame"],
          "fa" => printing["fullart"],
          "fe" => printing["frame_effects"],
          "fl" => printing["flavor"],
          "fn" => printing["flavor_name"],
          "fo" => printing["foiling"],
          "g" => printing["digital"],
          "l" => printing["language"],
          "m" => printing["mtgo"],
          "mv" => printing["multiverseid"],
          "n" => printing["number"],
          "nt" => printing["nontournament"],
          "o" => printing["others"],
          "os" => printing["oversized"],
          "p" => printing["paper"],
          "pr" => printing["partner"],
          "ps" => printing["print_sheet"],
          "pt" => printing["promo_types"],
          "r" => rarity_code,
          "sg" => printing["signature"],
          "sh" => printing["shandalar"],
          "sp" => printing["spotlight"],
          "ss" => printing["subsets"],
          "st" => printing["stamp"],
          "t" => printing["token"], # there could be token and card with the same name?
          "tl" => printing["textless"],
          "ts" => printing["timeshifted"],
          "vf" => printing["variant_foreign"],
          "vm" => printing["variant_misprint"],
          "w" => printing["watermark"],
          "x" => printing["xmage"],
        }.compact
      ]
    end

    result = common_card_data[0]
    name = result["n"]
    # Make sure it's reconciled at this point
    # This should be hard error once we're done
    report_if_inconsistent(name, common_card_data, card)

    # Output in canonical form, to minimize diffs between mtgjson updates
    result["*"] = printing_data.sort_by{|sc,d|
      [set_order.fetch(sc), d["n"], d["mv"] || 0]
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
