describe "FNM" do
  include_context "db", "fnmp"

  it "year" do
    "year = 2000".should have_result_count 11
    "year < 2003".should have_result_count 30
    "year > 2004".should equal_result "year >= 2005 "
  end
end
