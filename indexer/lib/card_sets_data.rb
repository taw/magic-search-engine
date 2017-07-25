class CardSetsData
  def initialize
    json_path = Indexer::ROOT + "AllSets-x.json"
    @data = JSON.parse(json_path.read)
  end

  def each_set(&block)
    @data.each(&block)
  end
end
