class Product
  attr_reader :name, :slug, :set, :data, :contents

  def initialize(set, data)
    @set = set
    @name = data["name"]
    @slug = name.downcase.gsub(/[^a-z0-9\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]+/, "_")
    @data = data
    @contents = data["contents"]
  end

  def set_code
    @set.code
  end
end
