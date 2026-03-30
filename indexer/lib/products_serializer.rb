class ProductsSerializer
  def initialize(products)
    @products = products
  end

  def to_s
    JSON.pretty_generate(
      @products.map{|product|
        product.merge(
          "release_date" => product["releaseDate"],
        ).compact.except("setCode", "releaseDate", "cardCount")
      }.sort_by{|product| [product["set_code"], product["name"]]}
    )
  end
end
