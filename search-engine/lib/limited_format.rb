# One limited format of one set, like "draft" or "prerelease-sealed"
#
# The data is whatever indexer/bin/limited_formats_indexer exported for it.
# Only the parts the frontend needs are unpacked so far.
class LimitedFormat
  attr_reader :db, :set, :type, :data

  def initialize(db, set, type, data)
    @db = db
    @set = set
    @type = type
    @data = data
  end

  def set_code
    @set.code
  end

  # "draft" or "sealed" - "prerelease-sealed" is a sealed format
  def format_type
    @data["format_type"]
  end

  # "commander", "two-headed-giant" etc. for sets not played like normal limited
  def play_variant
    @data["play_variant"]
  end

  # Packs of a draft, in the order they are opened
  def booster_order
    (@data["booster_order"] || []).map{|code|
      pack = @db.supported_booster_types[code]
      warn "#{inspect} uses unknown booster #{code}" unless pack
      pack
    }.compact
  end

  def slug
    @type
  end

  def inspect
    "LimitedFormat(#{set_code}, #{type})"
  end

  def to_s
    "#{@set.name} #{@type.split("-").map(&:capitalize).join(" ")}"
  end
end
