describe "Stamp" do
  include_context "db"

  def printings_matching(&block)
    db.printings.select(&block)
  end

  let(:stamps) { db.printings.map(&:stamp).compact.uniq }

  it "every stamp effect has corresponding stamp: operator" do
    stamps.each do |stamp|
      "stamp:#{stamp}".should return_printings(
        printings_matching{|c| c.stamp == stamp }
      )
    end
  end

  it "stamp:* matches any stamp" do
    "stamp:*".should return_printings(printings_matching{|c| !!c.stamp })
  end

  it "every stamp: also works as is:" do
    stamps.each do |stamp|
      next if stamp == "arena" # is:arena already used for something else
      assert_search_equal "stamp:#{stamp}", "is:#{stamp}"
    end
  end
end
