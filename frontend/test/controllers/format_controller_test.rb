require 'test_helper'

class FormatControllerTest < ActionController::TestCase
  test "index" do
    get "index"
    assert_response 200
    assert_select %Q[a:contains("Commander")]
    assert_select %Q[a:contains("Modern")]
    assert_select %Q[a:contains("Shards of Alara Block")]
  end

  test "show - fake format" do
    get "show", id: "return-to-homelands-block"
    assert_response 404
  end

  test "show - Scars of Mirrodin Block" do
    get "show", id: "scars-of-mirrodin-block"
    assert_response 200
    assert_select %Q[title:contains("Scars of Mirrodin Block")]
    assert_select %Q[h3:contains("Scars of Mirrodin Block")]
    assert_select %Q[a:contains("Scars of Mirrodin")]
    assert_select %Q[a:contains("Mirrodin Besieged")]
    assert_select %Q[a:contains("New Phyrexia")]
    assert_select %Q[p:contains("There are no banned cards.")]
    assert_select %Q[p:contains("There are no restricted cards.")]
  end

  test "show - Innistrad Block" do
    get "show", id: "innistrad-block"
    assert_response 200
    assert_select %Q[title:contains("Innistrad Block")]
    assert_select %Q[h3:contains("Innistrad Block")]
    assert_select %Q[a:contains("Innistrad")]
    assert_select %Q[a:contains("Dark Ascension")]
    assert_select %Q[a:contains("Avacyr Restored")]
    assert_select %Q[a:contains("Lingering Souls")]
    assert_select %Q[p:contains("There are no restricted cards.")]
  end
end
