describe "Indexer Fixes Test" do
  include_context "db"

  it "rqs" do
    %W[basic common uncommon rare].each do |rarity|
      (search("e:rqs r:#[rarity}") - search("e:4e r:#[rarity}")).should be_empty
    end
    (search("e:rqs -r:rare -r:uncommon -r:common -r:basic")).should be_empty
  end

  it "itp" do
    %W[basic common uncommon rare].each do |rarity|
      (search("e:rqs r:#[rarity}") - search("e:4e r:#[rarity}")).should be_empty
    end
    (search("e:itp -r:rare -r:uncommon -r:common -r:basic")).should be_empty
  end
end
