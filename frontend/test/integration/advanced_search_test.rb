require 'test_helper'

class AdvancedSearchTest < ActionDispatch::IntegrationTest
  test "name - single word" do
    visit "/advanced"
    fill_in "advanced[name]", with: "Delver"
    assert_redirected_to_search "Delver"
  end

  test "name - multiple words" do
    visit "/advanced"
    fill_in "advanced[name]", with: "Delver of Secrets"
    assert_redirected_to_search "Delver of Secrets"
  end

  test "name - quoted" do
    visit "/advanced"
    fill_in "advanced[name]", with: '"Delver of Secrets"'
    assert_redirected_to_search '"Delver of Secrets"'
  end

  test "name - unusual characters" do
    visit "/advanced"
    fill_in "advanced[name]", with: 'en-kor'
    assert_redirected_to_search '"en-kor"'
  end

  test "type" do
    visit "/advanced"
    fill_in "advanced[type]", with: "legendary dragon"
    assert_redirected_to_search "t:legendary t:dragon"
  end

  test "artist" do
    visit "/advanced"
    fill_in "advanced[artist]", with: '"steve argyle"'
    assert_redirected_to_search 'a:"steve argyle"'
  end

  test "flavor text" do
    visit "/advanced"
    fill_in "advanced[flavor]", with: %Q[here's some gold]
    assert_redirected_to_search %Q[ft:"here's" ft:some ft:gold]
  end

  test "oracle" do
    visit "/advanced"
    fill_in "advanced[oracle]", with: '"3 damage to target" creature player'
    assert_redirected_to_search %Q[o:"3 damage to target" o:creature o:player]
  end

  test "rarity" do
    visit "/advanced"
    click_checkbox("rarity", "uncommon")
    click_checkbox("rarity", "rare")
    assert_redirected_to_search %Q[(r:rare OR r:uncommon)]
  end

  test "rarity - any resets selection" do
    visit "/advanced"
    click_checkbox("rarity", "uncommon")
    click_checkbox("rarity", "rare")
    click_checkbox("rarity", "any")
    click_checkbox("rarity", "common")
    assert_redirected_to_search %Q[r:common]
  end

  test "set" do
    visit "/advanced"
    click_checkbox("set", "m10")
    click_checkbox("set", "m11")
    assert_redirected_to_search %Q[e:m10,m11]
  end

  test "set - any resets selection" do
    visit "/advanced"
    click_checkbox("set", "m10")
    click_checkbox("set", "m11")
    click_checkbox("set", "any")
    click_checkbox("set", "m12")
    assert_redirected_to_search %Q[e:m12]
  end

  test "block" do
    visit "/advanced"
    click_checkbox("block", "time_spiral")
    click_checkbox("block", "lorwyn")
    assert_redirected_to_search %Q[b:lw,ts]
  end

  test "block - any resets selection" do
    visit "/advanced"
    click_checkbox("block", "time_spiral")
    click_checkbox("block", "lorwyn")
    click_checkbox("block", "any")
    click_checkbox("block", "theros")
    assert_redirected_to_search %Q[b:ths]
  end

  test "set or block" do
    visit "/advanced"
    click_checkbox("block", "scars_of_mirrodin")
    click_checkbox("set", "m12")
    assert_redirected_to_search %Q[(b:som OR e:m12)]
  end

  test "watermark" do
    visit "/advanced"
    click_checkbox("watermark", "mirran")
    click_checkbox("watermark", "phyrexian")
    assert_redirected_to_search %Q[(w:mirran OR w:phyrexian)]
  end

  test "watermark - yes" do
    visit "/advanced"
    click_checkbox("watermark", "has_watermark")
    assert_redirected_to_search %Q[w:*]
  end

  test "watermark - no" do
    visit "/advanced"
    click_checkbox("watermark", "no_watermark")
    assert_redirected_to_search %Q[-w:*]
  end

  private

  def click_checkbox(group, value)
    find("#advanced_#{group}_#{value}").click
  end

  def assert_redirected_to_search(query)
    click_on "Search"
    assert_equal query, page.find_field("q").value
  end
end
