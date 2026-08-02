require "rails_helper"

RSpec.describe ProductController, type: :controller do
  render_views

  let(:set) { $CardDatabase.sets.values.find{|s| s.products.present?} }
  let(:product) { set.products.first }

  it "list of products" do
    get "index"
    assert_response 200
    assert_equal "Sealed Products - #{APP_NAME}", html_document.title
    assert_select %[li:contains("#{product.name}")]
  end

  it "actual product" do
    get "show", params: {set: set.code, id: product.slug}
    assert_response 200
    assert_equal "#{product.name} - #{set.name} - #{APP_NAME}", html_document.title
    assert_select %[h3:contains("#{product.name}")]
  end

  it "fake set" do
    get "show", params: {set: "lolwtf", id: product.slug}
    assert_response 404
  end

  it "fake product for real set" do
    get "show", params: {set: set.code, id: "lolwtf"}
    assert_response 404
  end
end
