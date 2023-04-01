require "json"
require "pathname"
require "pry"
require "yaml"

class BoosterIndexer
  ROOT = Pathname(__dir__).parent.parent
  BOOSTER_DATA_ROOT = ROOT + "data/boosters"
  BOOSTER_INDEX_PATH = ROOT + "index/booster_index.json"

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

  def merge_pack_parts(part1, part2)
    result = part1.dup
    part2.each do |k, v|
      result[k] ||= 0
      result[k] += v
    end
    result
  end

  def resolve_option_combinations(pack_data)
    options = [[{}, pack_data.delete("chance") || 1]]
    pack_data.each do |name, count|
      if count.is_a?(Integer)
        options = options.map{|o,c|
          [merge_pack_parts(o, {name => count}), c]
        }
      elsif count.is_a?(Array)
        merge_options = count.map{|m| [m, m.delete("chance")]}
        options = options.flat_map{|o1, c1|
          merge_options.map{|o2, c2|
            [merge_pack_parts(o1, o2), c1 * c2]
          }
        }
      else
        raise "Unknown pack count type #{count.class}"
      end
    end
    options
  end

  def process_booster(name, data)
    packs = data.delete("packs") || []
    packs << data.delete("pack") if data.key?("pack")
    raise "Booster #{name} has no packs" if packs.empty?
    packs = packs.flat_map{|pack_data| resolve_option_combinations(pack_data)}
    gcd = packs.map(&:last).reduce(:gcd)
    data["packs"] = packs.map{|pack_data, chance| [pack_data, chance / gcd]}
  end

  def process_data
    @boosters.each do |name, data|
      process_booster(name, data)
    end
  end

  def call
    load_data
    process_data
    BOOSTER_INDEX_PATH.write({
      "common" => @common,
      "boosters" => @boosters
    }.to_json)
  end
end
