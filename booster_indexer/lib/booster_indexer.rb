require "json"
require "pathname"
require "pry"
require "yaml"

class BoosterIndexer
  ROOT = Pathname(__dir__).parent.parent
  BOOSTER_DATA_ROOT = ROOT + "data/boosters"
  BOOSTER_INDEX_PATH = INDEX_ROOT + "index/booster_index.json"

  def initialize
    @common = nil
    @boosters = {}
  end

  def load_data
    BOOSTER_DATA_ROOT.glob("*.yaml").each do |path|
      basename = path.basename(".yaml").to_s.gsub("_", "")
      if basename == "common"
        @common = YAML.load_file(path)
      else
        @boosters[basename] = YAML.load_file(path)
      end
    end
  end

  def call
    load_data
    # process data
    BOOSTER_INDEX_PATH.write({
      "common" => @common,
      "boosters" => @boosters
    }.to_json)
  end
end
