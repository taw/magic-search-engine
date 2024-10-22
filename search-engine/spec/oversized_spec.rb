describe "Oversized cards" do
  include_context "db"

  it "is:oversized" do
    assert_search_equal "is:oversized -e:p09,p10,p11", "(t:plane or t:phenomenon or t:scheme or e:pcmd,oc13,oc14,oc15,oc16,oc17,oc18,oc19,oc20,oc21,ocm1,ocmd,ppc1,phel,ovnt,olgc,pvan,pmic,oafc,olep,o90p or (Baldur's Gate Wilderness)) -e:da1"
    assert_search_equal "not:oversized", "-(is:oversized)"
  end
end
