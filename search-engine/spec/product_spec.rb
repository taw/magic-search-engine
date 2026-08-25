# This is warning only, as we know data is incomplete
describe "product queries" do
  include_context "db"

  # most of this mapping is already done in Product, so just report results here
  it "all linked cards, products, packs, and decks exist" do
    db.products.each do |product|
      verify_contents(product.set, product.name, product.contents)
    end
  end

  def verify_contents(product_set, product_name, contents)
    contents.each do |count, item|
      case item
      when Product, Pack, Deck
        # OK
      when PhysicalCard
        printing = item.main_front
        if item.foil and printing.nonfoilonly?
          warn "Product #{product_name} contains foil card #{item.set_code} #{item.number} #{item.name}, but it's only available nonfoil"
        elsif (!item.foil) and printing.foilonly?
          warn "Product #{product_name} contains nonfoil card #{item.set_code} #{item.number} #{item.name}, but it's only available foil"
        end
      when String # other, variable, unknown contents, or unknown <type>
        if item.start_with?("unknown") and item != "unknown contents"
          # Ignore unknown contents in partial previews, they are unavoidable
          next if product_set.types.include?("preview")
          warn "Product #{product_name} contains #{item}"
        end
      when ProductVariableContents
        item.options.each do |option|
          verify_contents(product_set, product_name, option[:subproduct])
        end
      else
        raise "Unknown content type: #{item.class}"
      end
    end
  end
end
