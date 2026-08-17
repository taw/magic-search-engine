describe SearchResults do
  include_context "db", "arn", "3ed", "4ed"

  let(:results) { db.search("t:djinn") }

  describe "#card_groups" do
    it "groups printings of the same card together" do
      results.card_groups.map{|group| group.map(&:id)}.should eq [
        ["arn/48"],
        ["arn/29"],
        ["4ed/84", "3ed/66"],
        ["3ed/166", "arn/42"],
        ["arn/18"],
        ["arn/19"],
      ]
    end

    it "keeps printings apart when the query asked for it" do
      db.search("t:djinn ++").card_groups.map(&:size).uniq.should eq [1]
    end
  end

  describe ".best_printing" do
    let(:printings) { db.search("!Mahamoti Djinn").printings }

    it "picks the first printing when we have no pictures" do
      printings.map(&:image_path).should eq [nil, nil]
      SearchResults.best_printing(printings).id.should eq "4ed/84"
    end

    it "prefers a printing we have a picture of" do
      # image_path is filled in by the frontend, from the pictures on disk
      begin
        printings[1].image_path = "/cards/3ed/66.png"
        SearchResults.best_printing(printings).id.should eq "3ed/66"
      ensure
        printings[1].image_path = nil
      end
    end

    it "has nothing to pick from an empty list" do
      SearchResults.best_printing([]).should eq nil
    end
  end

  describe "#best_printings" do
    it "returns one printing per card, in result order" do
      results.best_printings.map(&:id).should eq %W[arn/48 arn/29 4ed/84 3ed/166 arn/18 arn/19]
    end
  end
end
