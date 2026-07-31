describe "watermark: queries" do
  context "New Phyrexia" do
    include_context "db", "nph"

    it "watermark:" do
      assert_search_results "w:mirran c:g", "Greenhilt Trainee", "Melira, Sylvok Outcast", "Viridian Harvest"
      assert_search_equal "w:mirran OR w:phyrexian", "w:*"
      assert_search_equal "-w:mirran -w:phyrexian", "-w:*"
      assert_search_equal "has:watermark", "w:*"
    end
  end

  context "Return to Ravnica block" do
    include_context "db", "rtr", "gtc", "dgm"

    it "watermark:" do
      assert_search_include "w:gruul", "Rubblebelt Raiders"
      assert_search_include "w:boros", "Aurelia, the Warleader"
      assert_search_exclude "w:gruul", "Aurelia, the Warleader"
    end
  end
end
