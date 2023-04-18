describe "Signature queries" do
  include_context "db"

  it "signature:*" do
    assert_search_equal "signature:*", "border:gold (e:World or e:ptc)"
  end

  it "aliases" do
    assert_search_equal "signature:Šlemr", "signature:Slemr"
    assert_search_equal "signature:Geertsen", "sig:GEERTSEN"
    assert_search_equal "signature:*", "has:signature"
  end
end
