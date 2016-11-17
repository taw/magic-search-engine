require 'test_helper'

class FormatControllerTest < ActionController::TestCase
  test "index" do
    get "index"
    assert_response 200
    assert_select %Q[li:contains("Commander")]
    assert_select %Q[li:contains("Modern")]
    assert_select %Q[li:contains("Shards of Alara Block")]
  end
end
