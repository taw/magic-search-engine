require "calc"
require "json"
require "pathname"
require "pry"
require "yaml"

class PreprocessBooster
  def initialize(indexer, name, data)
    @indexer = indexer
    @name = name
    @data = data
  end

  def common
    @indexer.common
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

  def eval_math(data)
    data.each do |k, v|
      if v.is_a?(Hash)
        eval_math(v)
      elsif v.is_a?(Array)
        data[k] = v.map{|vv| eval_math(vv)}
      elsif ["chance", "count", "rate"].include?(k) and v.is_a?(String)
        data[k] = Calc.evaluate(v)
      end
    end
  end

  def initialize_pack
    packs = []
    [@data["packs"], @data["pack"]].compact.each do |pack_data|
      if pack_data.is_a?(Hash)
        packs += [pack_data]
      else
        packs += pack_data
      end
    end
    packs = packs.flat_map{|pack_data| resolve_option_combinations(pack_data)}
    raise "Booster #{name} has no packs" if packs.empty?
    gcd = packs.map(&:last).reduce(:gcd)
    @pack = packs.map{|pack_data, chance| [pack_data, chance / gcd]}
  end

  def find_sheets_in_use
    @pack.flat_map{|pack, _| pack.keys}.to_set
  end

  def warn_about_conflicts_with_common_sheets
    (@data["sheets"] || {}).each do |sheet_name, sheet|
      if sheet == common[sheet_name]
        warn "Sheet #{@name}/#{sheet_name} is identical to common sheet with the same name, you can remove it"
      end
    end
  end

  def initialize_sheets
    @sheets = common.merge(@data["sheets"] || {})
  end

  def resolve_sheet_references(sheet)
    if sheet["use"]
      use = sheet.delete("use")
      raise "In #{@name} use:#{use} but no such sheet found" unless @sheets[use]
      sheet.replace @sheets[use].merge(sheet)
      # Call it again in case there's an use chain
      resolve_sheet_references(sheet)
    elsif sheet["any"]
      sheet["any"].each do |subsheet|
        resolve_sheet_references(subsheet)
      end
    end
  end

  def resolve_sheets_references
    @sheets.each do |sheet_name, sheet|
      resolve_sheet_references(sheet)
    end
  end

  def call
    eval_math(@data)
    initialize_pack
    sheets_in_use = find_sheets_in_use

    warn_about_conflicts_with_common_sheets
    initialize_sheets
    resolve_sheets_references

    {
      "pack" => @pack,
      "sheets" => @sheets.select{|k,v| sheets_in_use.include?(k)},
    }
  end
end

class BoosterIndexer
  ROOT = Pathname(__dir__).parent.parent
  BOOSTER_DATA_ROOT = ROOT + "data/boosters"
  BOOSTER_INDEX_PATH = ROOT + "index/booster_index.json"

  attr_reader :common

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

  def process_data
    @boosters.each do |name, data|
      @boosters[name] = PreprocessBooster.new(self, name, data).call
    end
  end

  def call
    load_data
    process_data
    BOOSTER_INDEX_PATH.write(@boosters.to_json)
  end
end
