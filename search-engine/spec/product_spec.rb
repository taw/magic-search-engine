# This is warning only, as we know data is incomplete
describe "product queries" do
  include_context "db"

  # most of this mapping is already done in Product, so just report results here
  it "all linked cards, products, packs, and decks exist" do
    db.products.each do |product|
      verify_contents(product.name, product.contents)
    end
  end

  def verify_contents(product_name, contents)
    contents.each do |count, item|
      case item
      when Product, Pack, Deck
        # OK
      when PhysicalCard
        product_foil = item.foil
        db_foiling = item.main_front.foiling
        if item.foil and db_foiling == :nonfoil
          warn "Product #{product_name} contains foil card #{item.set_code} #{item.number} #{item.name}, but it's only available nonfoil"
        elsif (!item.foil) and db_foiling == :foilonly
          warn "Product #{product_name} contains nonfoil card #{item.set_code} #{item.number} #{item.name}, but it's only available foil"
        end
      when String # other, variable, unknown contents, or unknown <type>
        if item.start_with?("unknown") and item != "unknown contents"
          warn "Product #{product_name} contains #{item}"
        end
      when ProductVariableContents
        p product_name
        item.options.each do |option|
          verify_contents(product_name, option[:subproduct])
        end
      else
        raise "Unknown content type: #{item.class}"
      end
    end
  end
end
