class CardSetsData
  def initialize
    @data = set_paths.map{|path| JSON.parse(path.read)}.map{|set|
      [set["code"], set]
    }.sort_by{|set_code, set|
      [set["releaseDate"] || "9999-12-31", set_code]
    }.to_h
  end

  def sets_path
    Indexer::ROOT + "sets"
  end

  def set_paths
    @set_paths ||= sets_path.glob("*.json").sort_by{|x| x.to_s.downcase}
  end

  def each_set(&block)
    @data.each(&block)
  end
end
