describe "promo types queries" do
  include_context "db"

  def printings_matching(&block)
    db.printings.select(&block)
  end

  let(:promo_types) { db.promo_types }

  it "every promo type has corresponding promo: operator" do
    promo_types.each do |promo_type|
      "promo:#{promo_type}".should return_printings(
        printings_matching{|c| c.promo_types&.include?(promo_type)}
      )
    end
  end
end
