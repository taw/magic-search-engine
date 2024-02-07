require "calc"
require "json"
require "pathname"
require "pry"
require "yaml"
require "set"

class Hash
  unless method_defined?(:except)
    def except(*keys)
      reject { |k, _| keys.include?(k) }
    end
  end
end

class PreprocessBooster
  def initialize(indexer, code, data)
    @indexer = indexer
    @code = code
    @set_code, @variant = code.split("-", 2)
    @variant ||= "default"
    @data = data
    @filter = "e:#{@set_code} is:baseset"
    if @data["filter"]
      @filter = @data["filter"]
    end
    @name = data["name"]
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
    raise "Booster #{@code} has no packs" if packs.empty?
    gcd = packs.map(&:last).reduce(:gcd)
    @pack = packs.map{|pack_data, chance| [pack_data, chance / gcd]}
  end

  def find_sheets_in_use
    @pack.flat_map{|pack, _| pack.keys}.to_set
  end

  def warn_about_conflicts_with_common_sheets
    (@data["sheets"] || {}).each do |sheet_name, sheet|
      if sheet == common[sheet_name]
        warn "Sheet #{@code}/#{sheet_name} is identical to common sheet with the same name, you can remove it"
      end
    end
  end

  def initialize_sheets
    @sheets = common.merge(@data["sheets"] || {})
  end

  def process_sheet(sheet, filter)
    if sheet["filter"]
      filter = sheet["filter"]
      sheet = sheet.except("filter")
    end
    if sheet["use"]
      use = sheet["use"]
      raise "In #{@code} use:#{use} but no such sheet found" unless @sheets[use]
      # Call it again in case there's an use chain
      # and then to do any other kind of processing
      process_sheet(@sheets[use].merge(sheet.except("use")), filter)
    elsif sheet["any"]
      sheet.merge(
        "any" => sheet["any"].map{|subsheet| process_sheet(subsheet, filter)}
      )
    elsif sheet["code"]
      if sheet["code"].include?("/")
        sheet
      else
        set = sheet["set"] || @set_code
        code = sheet["code"]
        sheet.except("code", "set").merge("code" => "#{set}/#{code}")
      end
    elsif sheet["deck"]
      sheet
    elsif sheet["rawquery"]
      query = sheet["rawquery"]
      sheet.except("rawquery").merge("query" => query.gsub("{set}", @set_code))
    elsif sheet["query"]
      query = sheet["query"]
      # filter already in and-form, doesn't need extra parentheses
      sheet.merge("query" => "(#{filter}) (#{query})".gsub("{set}", @set_code).gsub("()", ""))
    else
      raise "Unknown sheet type #{sheet.keys.join(", ")}"
    end
  end

  def process_sheets
    @sheets = @sheets.transform_values do |sheet|
      process_sheet(sheet, @filter)
    end
  end

  def check_small_balanced_sheets
    @pack.each do |pack, chance|
      pack.each do |sheet_name, count|
        if @sheets[sheet_name].nil?
          raise "Missing sheet #{@name}/#{sheet_name}"
        end
        next unless @sheets[sheet_name]["balanced"]
        # exact number depends on number of non-mono-color-identity cards
        # <4 is literally impossible
        # 5 is pretty much not doable, you literally need to split it into 5 subsheets, which is technically true if all colors' counts are identical
        # 6-7 is warning zone, doability depends on number of cards with CI!=1
        # 8+ should be fine
        if count <= 6
          warn "Sheet #{@code}/#{sheet_name} is too small to be balanced with only #{count} cards"
        end
      end
    end
  end

  def initialize_name
    @name ||= case @variant
    when "default"
      "{set_name}"
    when "arena"
      "{set_name} Arena Booster"
    when "set"
      "{set_name} Set Booster"
    when "collector"
      "{set_name} Collector Booster"
    when "collector-sample"
      "{set_name} Collector Sample Booster"
    when "jp"
      "{set_name} Japanese Draft Booster"
    when "set-jp"
      "{set_name} Japanese Set Booster"
    when "collector-jp"
      "{set_name} Japanese Collector Booster"
    when "prerelease"
      "{set_name} Prerelease Promo Pack"
    when "six"
      "{set_name} Six-card Booster Pack"
    when "play"
      "{set_name} Play Booster"
    when "play-arena"
      "{set_name} Arena Play Booster"
    when "draft"
      "{set_name} Draft Booster"
    else
      warn "Unknown booster type: #{@code}"
      "{set_name} #{@variant.capitalize} Booster"
    end
  end

  def call
    initialize_name
    eval_math(@data)
    initialize_pack
    sheets_in_use = find_sheets_in_use

    warn_about_conflicts_with_common_sheets
    initialize_sheets
    process_sheets
    check_small_balanced_sheets

    {
      "name" => @name,
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
      basename = path.basename(".yaml").to_s.delete("_")
      if basename == "common"
        @common = YAML.load_file(path)
      else
        @boosters[basename] = YAML.load_file(path)
      end
    end
  end

  def process_data
    @boosters.each do |code, data|
      @boosters[code] = PreprocessBooster.new(self, code, data).call
    end
  end

  def call
    load_data
    process_data
    BOOSTER_INDEX_PATH.write(@boosters.to_json)
  end
end
