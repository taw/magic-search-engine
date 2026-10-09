require_relative "../../indexer/lib/deck_printing_resolver"

describe "Full-art deck wildcards" do
  let(:db) { CardDatabase.load }

  def resolve_land(name, count, fullart)
    printings = db.search("s:bfz t:basic").printings.select{|c| c.name == name}.map do |c|
      {"name" => name, "set_code" => "bfz", "number" => c.number,
       "fullart" => c.fullart, "frame_effects" => c.frame_effects,
       "border" => c.border, "finishes" => ["nonfoil", "foil"]}
    end
    card = {"name" => name, "set" => "BFZ", "number" => "*", "count" => count}
    card["fullart"] = true if fullart
    DeckPrintingResolver.new({name => printings}, [], {}, {"set_code" => "ogw"}, card).call
  end

  it "round-robins only the five full-art printings of each colored basic" do
    %w[Plains Island Swamp Mountain Forest].each_with_index do |name, i|
      result = resolve_land(name, i == 0 ? 14 : 13, true)
      result.map{|row| row[2]}.should eq((250+i*5..254+i*5).map(&:to_s))
      result.sum{|row| row[0]}.should eq(i == 0 ? 14 : 13)
      result.all?{|row| row.size == 3}.should be true
    end
  end

  it "keeps unqualified BFZ wildcards on regular-frame printings" do
    result = resolve_land("Plains", 14, false)
    result.map{|row| row[2]}.should eq((250..254).map{|n| "#{n}a"})
  end
end
