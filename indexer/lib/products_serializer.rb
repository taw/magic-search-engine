class ProductsSerializer
  def initialize(products)
    @products = products
  end

  # One product per line
  def to_s
    @products.map{|product|
      product.merge(
        "release_date" => product["releaseDate"],
      ).compact.except("setCode", "releaseDate", "cardCount")
    }.sort_by{|product| [product["set_code"], product["name"]]}
      .map{|product| product.to_json << "\n" }
      .join
  end
end
