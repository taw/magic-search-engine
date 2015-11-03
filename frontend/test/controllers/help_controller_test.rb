require 'test_helper'

class HelpControllerTest < ActionController::TestCase
  test "smoke test" do
    get "syntax"
    assert_response 200
    assert_select %Q[h3:contains("Search Help")]
  end
end
