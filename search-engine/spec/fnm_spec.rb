describe "FNM" do
  include_context "db", "fnmp"

  it "year" do
    "year = 2000".should have_count_printings 11 # ???
    "year < 2003".should have_count_printings 30 # ???
    "year > 2004".should equal_search "year >= 2005"
  end
end
