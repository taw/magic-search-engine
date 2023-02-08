class ProductsSerializer
  def initialize(products)
    @products = products
  end

  def to_s
    @products.map{|product|
      [
        product["set_code"],
        product["name"],
        product["category"],
        product["subtype"],
        product["uuid"],
        product["releaseDate"],
      ].join("\t") + "\n"
    }.join
  end
end
