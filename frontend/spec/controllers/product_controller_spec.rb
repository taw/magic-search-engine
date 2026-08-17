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

  # A booster box is packs, an intro pack is a deck and a pack, and a fat pack
  # is other products - each kind of content gets rendered differently
  it "shows what is in the box" do
    get "show", params: {set: "nph", id: "new_phyrexia_booster_box"}
    assert_response 200
    assert_select %[li:contains("36x")]
    assert_select %[li a[href="/pack/nph-draft"]:contains("New Phyrexia Draft Booster")]
  end

  it "links the deck inside an intro pack" do
    get "show", params: {set: "nph", id: "new_phyrexia_intro_pack_feast_of_flesh"}
    assert_response 200
    assert_select %[li a[href="/deck/nph/feast-of-flesh"]]
    assert_select %[li a[href="/pack/nph-draft"]]
  end

  it "nests the products inside a product" do
    get "show", params: {set: "nph", id: "new_phyrexia_intro_packs_set_of_5"}
    assert_response 200
    assert_select %[li a[href="/product/nph/new_phyrexia_intro_pack_feast_of_flesh"]]
    assert_select %[li a[href="/deck/nph/feast-of-flesh"]]
  end

  # Some products aren't always the same - a sample deck's rare slot varies
  it "shows the odds of a product with variable contents" do
    get "show", params: {set: "10e", id: "tenth_edition_sample_deck_ajani_goldmane"}
    assert_response 200
    assert_select %[li:contains("Variable contents")]
    assert_select %[li:contains("%)")]
  end

  it "shows contents we have no card or pack for as plain text" do
    get "show", params: {set: "3ed", id: "revised_edition_gift_box"}
    assert_response 200
    assert_select %[li:contains("other: Cloth Bag")]
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
