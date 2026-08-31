describe "Oversized cards" do
  include_context "db"

  # Oversized means a bigger copy of a card that also exists at normal size, so it is
  # only ever the display card and oversized promo sets. Planes, phenomena, schemes and
  # vanguards have no normal size to be bigger than, so mtgjson marking every one of
  # them oversized is dropped by PatchMtgjsonBugs.
  it "is:oversized" do
    # I don't trust da1/unk data either way
    assert_search_equal "is:oversized -e:p09,p10,p11,unk,punk", "e:pcmd,oc13,oc14,oc15,oc16,oc17,oc18,oc19,oc20,oc21,ocm1,ocmd,ppc1,phel,ovnt,olgc,pmic,oafc,olep,o90p or (Baldur's Gate Wilderness)"
    assert_search_equal "not:oversized", "-(is:oversized)"
  end

  # The flag mtgjson actually gets right for one of these types, and the reason we do
  # not trust it for the rest: paper vanguards are marked oversized and MTGO avatars are
  # not, but planes and schemes are marked on every printing, MTGO ones included.
  it "does not mark inherently big cards" do
    assert_search_results "(t:plane or t:phenomenon or t:scheme or t:vanguard) is:oversized"
  end
end
