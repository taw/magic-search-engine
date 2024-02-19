describe "booster:" do
  include_context "db"

  it "supports regular queries" do
    assert_search_equal "booster:nph", "e:nph"
    assert_search_equal "booster:lea", "e:lea"
    assert_search_equal "booster:m15", "e:m15 number:1-set"
  end

  it "supports special booster" do
    assert_search_equal "booster:ala-premium", "b:ala number:1-set" # fake Rafiq of the Many [ala/250] not there obviously
    assert_search_equal "booster:m20-arena", "e:m20 number:1-set -variant:misprint"
  end

  it "supports partial star" do
    assert_search_equal "booster:sir-*", "booster:sir-arena-1 or booster:sir-arena-2 or booster:sir-arena-3 or booster:sir-arena-4"
    assert_search_equal "booster:one-*", "booster:one or booster:one-set or booster:one-collector or booster:one-arena or booster:one-jumpstart or booster:one-prerelease or booster:one-compleat or booster:one-collector-sample"
  end

  it "supports full star" do
    assert_search_equal "booster:* e:m20", "booster:m20 e:m20"
    assert_search_equal "booster:* e:zen", "booster:zen e:zen"
  end

  it "supports multiple codes" do
    assert_search_equal "booster:m10,m11,m12", "booster:m10 or booster:m11 or booster:m12"
  end

  it "default type" do
    assert_search_equal "booster:m10", "booster:m10-draft"
    assert_search_equal "booster:mkm", "booster:mkm-play"
  end
end
