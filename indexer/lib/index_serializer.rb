require_relative "../../search-engine/lib/index_format"

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
        [name, index_card(name, card_data, set_order)]
      }.sort.to_h,
    }
    # Keep set index order as is, normalize everything else
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
      "languages",
      "name",
      "online_only",
      "release_date",
      "subsets",
      "token_set_code",
      "types",
    ).merge(
      "products" => (@products[set["code"]] || []).map{|x| index_product(x)}
    ).compact
  end

  # `default` (if given) is dropped from the index,
  # CardDatabase substitutes it back when the key is missing.
  def index_enum(value, list, name, default: false)
    return nil if value.nil?
    index = list.index(value) or raise "Unknown #{name} #{value.inspect}, add it to IndexFormat::#{name.upcase}"
    return nil if default and index == 0
    index
  end

  # Rulings share a date far more often than not, so group by it
  def index_rulings(rulings)
    return nil unless rulings
    rulings.each_with_object({}) do |ruling, result|
      (result[ruling["date"]] ||= []) << ruling["text"]
    end
  end

  # Nearly every card has exactly one name per language
  def index_foreign_names(foreign_names)
    return nil unless foreign_names
    foreign_names.transform_values{|names| names.size == 1 ? names[0] : names}
  end

  def index_flags(printing)
    flags = +""
    IndexFormat::FLAGS.each do |field, char|
      flags << char if printing[field]
    end
    IndexFormat::NEGATED_FLAGS.each do |field, char|
      flags << char unless printing[field]
    end
    flags.empty? ? nil : flags
  end

  def index_card(name, card, set_order)
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
        "f" => index_foreign_names(printing["foreign_names"]),
        "fu" => printing["funny"],
        "gc" => printing["game_changer"],
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
        "p" => printing["power"],
        "pr" => printing["produces"],
        "r" => index_rulings(printing["rulings"]),
        "rl" => printing["related"],
        "rs" => printing["reserved"],
        "s" => printing["secondary"],
        "sb" => printing["spellbook"],
        "sd" => printing["specialized"],
        "sn" => printing["short_name"],
        "ss" => printing["specializes"],
        "t" => printing["types"],
        "tb" => printing["subtypes"],
        "to" => printing["toughness"],
        "tp" => printing["supertypes"],
        "v" => printing["cmc"],
      }.compact

      rarity = printing["rarity"]
      rarity_code = IndexFormat::RARITIES.index(rarity) or raise "Unknown rarity #{rarity}"

      printing_data << [
        printing["set_code"],
        {
          "!" => index_flags(printing),
          "a" => printing["artist"],
          "al" => printing["attraction_lights"],
          "b" => index_enum(printing["border"], IndexFormat::BORDERS, "borders", default: true),
          "d" => printing["release_date"],
          "f" => index_enum(printing["frame"], IndexFormat::FRAMES, "frames", default: true),
          "fe" => printing["frame_effects"],
          "fl" => printing["flavor"],
          "fn" => printing["flavor_name"],
          "fo" => index_enum(printing["foiling"], IndexFormat::FOILINGS, "foilings", default: true),
          "l" => printing["language"],
          "m" => printing["multiverseid"],
          "n" => printing["number"],
          "o" => printing["others"],
          "p" => printing["promo_types"]&.sort,
          "pr" => printing["partner"],
          "ps" => printing["print_sheet"],
          "r" => rarity_code,
          "s" => index_enum(printing["stamp"], IndexFormat::STAMPS, "stamps"),
          "sg" => printing["signature"],
          "ss" => printing["subsets"],
          "w" => printing["watermark"],
        }.compact
      ]
    end

    result = common_card_data[0]
    # Make sure it's reconciled at this point
    # This should be hard error once we're done
    report_if_inconsistent(name, common_card_data, card)

    # The card name is already the key it's stored under, so don't repeat it
    card_name = result.delete("n")
    raise "Card name #{card_name.inspect} does not match index key #{name.inspect}" unless card_name == name

    # Output in canonical form, to minimize diffs between mtgjson updates
    result["*"] = printing_data.sort_by{|sc,d|
      [set_order.fetch(sc), d["n"], d["m"] || 0]
    }
    result
  end

  def report_if_inconsistent(name, common_card_data, card)
    return if common_card_data.uniq.size == 1
    keys = common_card_data.map(&:keys).inject(&:|)
    inconsistent_keys = keys.select{|key| common_card_data.map{|ccd| ccd[key]}.uniq.size > 1 }
    warn "Data for card #{name} inconsistent on #{inconsistent_keys.join(", ")}"

    # This is confusing due to keys compression
    inconsistent_keys.each do |key|
      warn "* #{key}: #{card.map{|c| c["set_code"]}.zip(common_card_data.map{|ccd| ccd[key]}).inspect}"
    end
  end
end
