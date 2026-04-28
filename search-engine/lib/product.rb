class Product
  attr_reader :name, :slug, :set, :data
  attr_accessor :contents

  def initialize(set, data)
    @set = set
    @name = data["name"]
    @slug = name.downcase.gsub(/[^a-z0-9\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]+/, "_")
    @data = data
    @contents = []
  end

  def set_code
    @set.code
  end

  def self.link_products(database)
    decks = database.decks.to_h{|d| [[d.set_code, d.name], d] }
    products = database.products.to_h{|p| [[p.set_code, p.name], p] }
    cards = database.sets.values.flat_map{|s| s.printings.map{|p| [[s.code, p.number], p]} }.to_h

    database.products.each do |product|
      product.contents = link(
        product.data["contents"],
        decks: decks,
        products: products,
        packs: database.supported_booster_types,
        cards: cards
      )
    end
  end

  # All the "unknown X" are known issues with data not being there
  # This will always happen for new sets
  def self.link(contents, decks:, products:, packs:, cards:)
    result = []

    contents.each do |count, type, *content|
      mapped = case type
      when "card"
        card = cards[[content[0], content[1]]]
        if card
          # no etched support
          PhysicalCard.for(card, content[3], false)
        else
          "unknown card: #{content[2]} [#{content[0].upcase}:#{content[1]}]#{ content[3] ? " [foil]": ""}"
        end
      when "deck"
        deck = decks[content]
        if deck
          deck
        else
          "unknown deck: #{content[1]} (#{content[0]})"
        end
      when "product"
        subproduct = products[content]
        if subproduct
          subproduct
        else
          "unknown product: #{content[1]} (#{content[0]})"
        end
      when "pack"
        pack = packs[content[0]]
        if pack
          pack
        else
          "unknown pack: #{content[0]}"
        end
      when "other"
        "other: #{content[0]}"
      when "unknown"
        "unknown contents"
      when "variable"
        ProductVariableContents.new(
          content[0].map do |option|
            {
              chance: option["chance"],
              total: option["total"],
              subproduct: link(option["subproduct"], decks: decks, products: products, packs: packs, cards: cards)
            }
          end
        )
      else
        raise "Unknown contents type: #{type}"
      end

      result << [count, mapped] if mapped
    end

    result
  end
end
