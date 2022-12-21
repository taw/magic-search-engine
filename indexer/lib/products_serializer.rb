class ProductsSerializer
  def initialize(products)
    @products = products
  end

  def to_s
    @products.map{|product| product.join("\t") + "\n"}.join
  end
end
