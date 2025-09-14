describe "produces queries" do
  include_context "db"

  it "parser" do
    assert_search_equal "produces:www", "PRODUCES:{W}"
    assert_search_equal "produces:{w/u}", "PRODUCES=WU"
    assert_search_equal "produces:{2/u}", "produces=u"
    assert_search_equal "produces:{pb}", "produces=b"

    assert_search_equal "produces>=wu", "produces=wu or produces>wu"
  end

  it "produces" do
    assert_search_include "produces=wub",
      "Raffine's Tower", # by land time
      "Dromar's Cavern", # by text
      "Ancient Spring" # by multiple texts

    assert_search_exclude "produces=wubrg",
      "Dromar's Cavern" # too few

    assert_search_include "produces>wub",
      "Birds of Paradise" # too many
  end
end
