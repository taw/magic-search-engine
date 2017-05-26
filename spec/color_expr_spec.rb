describe "Color Expr Test" do
  include_context "db"

  it "one color" do
    assert_search_equal "c=r", "c!r"
    assert_search_equal "c>=r", "c:r"
  end

  it "multiple colors" do
    assert_search_equal "c>=g c>=r", "c>=rg"
    assert_search_equal "c>g", "c>=g (c>=w or c>=u or c>=b or c>=r)"
  end

  it "other operators" do
    assert_search_equal "c>=gr", "c>r c>g"
    assert_search_equal "c<=gr", "c<=r or c<=g or c=gr"
  end

  it "ci - one color" do
    assert_search_equal "ci<=uw", "ci:uw"
  end

  it "ci multiple colors" do
    assert_search_equal "ci>=g ci>=r", "ci>=rg"
    assert_search_equal "ci>g", "ci>=g (ci>=w or ci>=u or ci>=b or ci>=r)"
  end

  it "ci other operators" do
    assert_search_equal "ci>=gr", "ci>r ci>g"
    assert_search_equal "ci<=gr", "ci<=r or ci<=g or ci=gr"
  end
end
