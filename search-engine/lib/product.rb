class Product
  attr_reader :name, :slug, :set, :data

  def initialize(set, data)
    @set = set
    @name = data["name"]
    @slug = name.downcase.gsub(/[^a-z0-9\p{Han}\p{Katakana}\p{Hiragana}\p{Hangul}]+/, "_")
    @data = data
  end

  def set_code
    @set.code
  end
end
