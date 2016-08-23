require 'test_helper'

class AdvancedSearchTest < ActionDispatch::IntegrationTest
  test "advanced search - name - single word" do
    visit "/advanced"
    fill_in "advanced[name]", with: "Delver"
    click_on "Search"
    assert_equal "Delver", page.find_field("q").value
  end

  test "advanced search - name - multiple words" do
    visit "/advanced"
    fill_in "advanced[name]", with: "Delver of Secrets"
    click_on "Search"
    assert_equal "Delver of Secrets", page.find_field("q").value
  end

  test "advanced search - name - quoted" do
    visit "/advanced"
    fill_in "advanced[name]", with: '"Delver of Secrets"'
    click_on "Search"
    assert_equal '"Delver of Secrets"', page.find_field("q").value
  end

  test "advanced search - name - unusual characters" do
    visit "/advanced"
    fill_in "advanced[name]", with: 'en-kor'
    click_on "Search"
    assert_equal '"en-kor"', page.find_field("q").value
  end

  test "advanced search - type" do
    visit "/advanced"
    fill_in "advanced[type]", with: "legendary dragon"
    click_on "Search"
    assert_equal "t:legendary t:dragon", page.find_field("q").value
  end

  test "advanced search - artist" do
    visit "/advanced"
    fill_in "advanced[artist]", with: '"steve argyle"'
    click_on "Search"
    assert_equal 'a:"steve argyle"', page.find_field("q").value
  end

  test "advanced search - flavor text" do
    visit "/advanced"
    fill_in "advanced[flavor]", with: %Q[here's some gold]
    click_on "Search"
    assert_equal %Q[ft:"here's" ft:some ft:gold], page.find_field("q").value
  end

  test "advanced search - oracle" do
    visit "/advanced"
    fill_in "advanced[oracle]", with: '"3 damage to target" creature player'
    click_on "Search"
    assert_equal %Q[o:"3 damage to target" o:creature o:player], page.find_field("q").value
  end
end
