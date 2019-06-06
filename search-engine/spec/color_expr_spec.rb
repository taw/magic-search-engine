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

  it "colorless" do
    assert_search_equal "c=c", "c<w"
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

  it "colorless" do
    assert_search_equal "ci=c", "ci<w"
  end

  it "is case insensitive" do
    assert_search_equal "ci=wur", "ci=WUR"
    assert_search_equal "c=wur", "c=WUR"
    assert_search_equal "CI=wur", "ci=WUR"
    assert_search_equal "C=wur", "c=WUR"
  end

  it "number of colors" do
    assert_search_equal "c=0", "c=c"
    assert_search_equal "c=1", "c=w or c=u or c=b or c=r or c=g"
    assert_search_equal "c>=3", "c=3 or c=4 or c=5"
    assert_search_equal "c>3", "c=4 or c=5"
    assert_search_equal "c<=3", "c=3 or c=2 or c=1 or c=0"
    assert_search_equal "c<3", "c=2 or c=1 or c=0"
    assert_search_results "c=w ci=5",
      "Bringer of the White Dawn",
      "General Tazri",
      "Paragon of the Amesha",
      "Sisay, Weatherlight Captain",
      "Who"
  end

  it "number of color identity" do
    assert_search_equal "ci=0", "ci=c"
    assert_search_equal "ci=1", "ci=w or ci=u or ci=b or ci=r or ci=g"
    assert_search_equal "ci>=3", "ci=3 or ci=4 or ci=5"
    assert_search_equal "ci>3", "ci=4 or ci=5"
    assert_search_equal "ci<=3", "ci=3 or ci=2 or ci=1 or ci=0"
    assert_search_equal "ci<3", "ci=2 or ci=1 or ci=0"
  end
end
