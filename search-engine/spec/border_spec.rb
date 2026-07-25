describe "border queries" do
  include_context "db"

  # Yellow borders were introduced by Aetherdrift
  it "border:yellow" do
    assert_search_equal "border:yellow", "is:yellow-bordered"
    assert_search_equal "-border:yellow", "not:yellow-bordered"
    assert_search_equal "border:yellow", "e:dft border:yellow"
    "border:yellow".should include_cards "Afterburner Expert", "Agonasaur Rex"
  end

  it "border: and is:*-bordered agree" do
    assert_search_equal "border:white t:creature", "is:white-bordered t:creature"
    assert_search_equal "border:yellow t:creature", "is:yellow-bordered t:creature"
  end

  it "borders are mutually exclusive" do
    borders = ["black", "white", "silver", "gold", "yellow", "borderless"]
    borders.combination(2) do |a, b|
      assert_search_results "border:#{a} border:#{b}"
    end
  end

  it "every border has a working border: and is: query" do
    db.printings.map(&:border).uniq.compact.each do |border|
      expected = db.printings.select{|c| c.border == border}
      "border:#{border}".should return_printings(expected)
      if border == "borderless"
        "is:borderless".should return_printings(expected)
      else
        "is:#{border}-bordered".should return_printings(expected)
      end
    end
  end
end
