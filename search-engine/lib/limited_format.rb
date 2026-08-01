# One limited format of one set, like "draft" or "prerelease-sealed"
#
# The data is whatever indexer/bin/limited_formats_indexer exported for it.
# It's not parsed any further yet.
class LimitedFormat
  attr_reader :set, :type, :data

  def initialize(set, type, data)
    @set = set
    @type = type
    @data = data
  end

  def set_code
    @set.code
  end

  def inspect
    "LimitedFormat(#{set_code}, #{type})"
  end

  def to_s
    inspect
  end
end
