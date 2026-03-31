# This is warning only, as we know data is incomplete
describe "product queries" do
  include_context "db"

  let(:valid_products) { db.products.map{|p| [p.set_code, p.name] }.to_set }
  let(:valid_boosters) { db.supported_booster_types.keys.to_set }
  let(:valid_decks) { db.decks.map{|d| [d.set_code, d.name] }.to_set }

  # check that all linked cards, products, packs, and decks exist
  it "all linked cards, products, packs, and decks exist" do
    db.products.each do |product|
      verify_contents(product.name, product.contents)
    end
  end

  def verify_contents(product_name, contents)
    contents.each do |count, type, *rest|
      case type
      when "product"
        set_code, name = *rest
        unless valid_products.include?([set_code, name])
          warn "Product #{product_name} contains unknown product #{set_code} #{name}"
        end
      when "pack"
        code, = *rest
        unless valid_boosters.include?(code)
          warn "Product #{product_name} contains unknown pack #{code}"
        end
      when "deck"
        set_code, name = *rest
        unless valid_decks.include?([set_code, name])
          warn "Product #{product_name} contains unknown deck #{set_code} #{name}"
        end
      when "card"
        set_code, number, name, foil = *rest
        raise "Unknown set code" unless db.sets[set_code]
        card = db.sets[set_code].printings.find{|p| p.name == name and p.number == number}
        if card
          if foil and card.foiling == :nonfoil
            warn "Product #{product_name} contains foil card #{set_code} #{number} #{name}, but it's only available nonfoil"
          elsif (!foil) and card.foiling == :foilonly
            warn "Product #{product_name} contains nonfoil card #{set_code} #{number} #{name}, but it's only available foil"
          end
        else
          warn "Product #{product_name} contains unknown card #{set_code} #{number} #{name}"
        end
      when "other", "unknown"
        # OK
      when "variable"
        rest[0].each do |subproduct|
          verify_contents(product_name, subproduct["subproduct"])
        end
      else
        raise "Unknown content type: #{type}"
      end
    end
  end
end
