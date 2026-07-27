require "calc"
require "json"
require "pathname"
require "pry"
require "yaml"
require "set"

class Hash
  # Builtin since Ruby 3.0; needed for 2.6 and 2.7.
  unless method_defined?(:except)
    def except(*keys)
      reject { |k, _| keys.include?(k) }
    end
  end
end

# Typo protection. Unlike data problems (missing cards, bad counts), which are
# routine during spoiler season, an unknown key is always an authoring mistake,
# so it's worth failing on.
module ValidateKeys
  TOP_LEVEL_KEYS = %W[
    name pack packs sheets queries filter superfilter languages
  ].to_set

  SHEET_KEYS = %W[
    query rawquery use any set code deck
    filter foil etched balanced fixed duplicates
    count chance rate
  ].to_set

  def validate_keys(keys, allowed, where)
    unknown = keys.to_set - allowed
    return if unknown.empty?
    raise "Unknown #{where}: #{unknown.sort.join(", ")} (known keys: #{allowed.sort.join(", ")})"
  end

  # Subsheets under `any` take the same keys as their parent
  def validate_sheet_keys(sheet, where)
    return unless sheet.is_a?(Hash)
    validate_keys(sheet.keys, SHEET_KEYS, "key in #{where}")
    sheet["any"].each_with_index do |subsheet, i|
      validate_sheet_keys(subsheet, "#{where} any[#{i}]")
    end if sheet["any"].is_a?(Array)
  end
end

class PreprocessBooster
  include ValidateKeys

  def initialize(indexer, code, data)
    @indexer = indexer
    @code = code
    @set_code, @variant = code.split("-", 2)
    @variant ||= "default"
    validate_keys(data.keys, TOP_LEVEL_KEYS, "key in #{code}.yaml")
    (data["sheets"] || {}).each do |sheet_name, sheet|
      validate_sheet_keys(sheet, "#{code}.yaml sheet #{sheet_name}")
    end
    @data = data
    @superfilter = @data["superfilter"] || ""
    @filter = @data["filter"] || "e:#{@set_code} is:baseset"
    @name = data["name"]
    # "en" or "fr, de", normalized to a list to match set languages
    languages = data.delete("languages")
    languages = languages.split(",").map(&:strip) if languages.is_a?(String)
    @languages = languages
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

  def initialize_queries
    @substitutions = {
      "{set}" => @set_code,
    }
    if @data["queries"]
      @data["queries"].each do |k, v|
        @substitutions["{#{k}}"] = "(#{v})"
      end
    end
    @substitutions_rx = Regexp.union(@substitutions.keys)
    # If it's all deeply recursive, it needs to be in order
    @substitutions.transform_values! do |v|
      v = v.gsub(@substitutions_rx){ @substitutions[$&] }
    end
  end

  def clean_query(query)
    # we could also cleanup () around it all
    query.gsub(@substitutions_rx){ @substitutions[$&] }.gsub("()", "").strip
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
      expanded_query = clean_query("(#{@superfilter}) (#{query})")
      warn_if_unresolved_template(expanded_query)
      sheet.except("rawquery").merge("query" => expanded_query)
    elsif sheet["query"]
      query = sheet["query"]
      # filter already in and-form, doesn't need extra parentheses
      expanded_query = clean_query("(#{@superfilter}) (#{filter}) (#{query})")
      warn_if_unresolved_template(expanded_query)
      sheet.merge("query" => expanded_query)
    else
      raise "Unknown sheet type #{sheet.keys.join(", ")}"
    end
  end

  def warn_if_unresolved_template(query)
    query.scan(/\{[^}]+\}/).each do |template|
      warn "Unresolved template #{template} in query #{query}, available substitutions: #{@substitutions.keys.join(", ")}"
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
    when "mtgo"
      "{set_name} Magic Online Booster"
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
    initialize_queries
    sheets_in_use = find_sheets_in_use

    warn_about_conflicts_with_common_sheets
    initialize_sheets
    process_sheets
    check_small_balanced_sheets

    {
      "name" => @name,
      "pack" => @pack,
      "sheets" => @sheets.select{|k,v| sheets_in_use.include?(k)},
      "languages" => @languages,
    }.compact
  end
end

class BoosterIndexer
  include ValidateKeys

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
        # common.yaml is a bare sheet map, with no top level keys of its own
        @common = YAML.load_file(path)
        @common.each do |sheet_name, sheet|
          validate_sheet_keys(sheet, "common.yaml sheet #{sheet_name}")
        end
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
