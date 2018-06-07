class Indexer
  class CardSet
    attr_reader :set_code, :set_data

    def initialize(set_code, set_data)
      @set_code = set_code
      @set_data = set_data
    end

    def to_json
      @set_data.slice(
        "name",
        "border",
        "type",
        "booster",
        "custom",
        "releaseDate",
      ).merge(
        "code" => @set_code,
        "gatherer_code" => @set_data["code"],
        "online_only" => @set_data["onlineOnly"],
      ).compact
    end
  end
end
