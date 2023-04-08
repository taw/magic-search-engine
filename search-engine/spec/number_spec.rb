describe "number: queries" do
  include_context "db"

  it "<=set" do
    assert_search_equal "e:war number<=set", "e:war number<=264"
  end

  it ">set" do
    assert_search_equal "e:m20 number>set", "e:m20 number>set"
  end

  it "ranges" do
    assert_search_equal "e:m20 number=100-200", "e:m20 number:100-200"
    assert_search_equal "e:m20 (number>=100 number<=200)", "e:m20 number:100-200"
    assert_search_equal "e:m20 ((number>=10 number<=20) or (number>=50 number<=60))", "e:m20 number:10-20,50-60"
    assert_search_equal "e:m20 (number=10 or number=20 or number=30)", "e:m20 number:10,20,30"
    assert_search_equal "e:m20 (number=10 or (number>=20 number<=30) or number=40)", "e:m20 number:10,20-30,40"
    assert_search_equal 'e:m20 number:"10,20-30,40"', "e:m20 number:10,20-30,40"
    assert_search_equal 'e:m20 number:"10-10,20-20,30"', "e:m20 number:10,20-20,30-30"
    assert_search_results "e:und number:75b-75d",
      "What", # 75b
      "When", # 75c
      "Where" # 75d
  end

  it "ranges with set" do
    assert_search_equal "e:m20 number=100-set", "e:m20 (number>=100 number<=set)"
    assert_search_equal "e:m20 number=set-set", "e:m20 number=set"
    assert_search_equal "e:m20 number=set-300", "e:m20 (number>=set number<=300)"
  end
end
