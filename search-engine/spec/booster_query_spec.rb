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

  it "supports star anywhere in the code" do
    assert_search_equal "booster:*-compleat", "booster:one-compleat"
    assert_search_equal "booster:*-arena e:war", "booster:war-arena"
    assert_search_equal "booster:*-arena e:blb", "booster:blb-play-arena e:blb"
    assert_search_equal "booster:*arena* e:sir", "booster:sir-* e:sir"
    assert_search_equal "booster:m2*-arena", "booster:m20-arena or booster:m21-arena"
    assert_search_equal "booster:sir-arena-*", "booster:sir-*"
    assert_search_equal "booster:one-collector*", "booster:one-collector or booster:one-collector-sample"
    assert_search_equal "booster:*", "booster:*-*"
  end

  it "supports full star" do
    assert_search_equal "booster:* e:m20", "booster:m20 e:m20"
    assert_search_equal "booster:* e:zen", "booster:zen e:zen"
  end

  it "supports multiple codes" do
    assert_search_equal "booster:m10,m11,m12", "booster:m10 or booster:m11 or booster:m12"
    assert_search_equal "booster:m20-arena,one-compleat", "booster:m20-arena or booster:one-compleat"
    assert_search_equal "booster:one-*,sir-*", "booster:one-* or booster:sir-*"
  end

  it "default type" do
    assert_search_equal "booster:m10", "booster:m10-draft"
    assert_search_equal "booster:mkm", "booster:mkm-play"
    assert_search_equal "booster:vma", "booster:vma-mtgo"
  end

  it "supports booster-foil: and booster-nonfoil:" do
    # everything available foil and nonfoil
    assert_search_equal "booster-nonfoil:nph", "booster:nph"
    assert_search_equal "booster-foil:nph", "booster:nph"
    # there are no foils
    assert_search_equal "booster-nonfoil:lea", "booster:lea"
    assert_search_results "booster-foil:lea"
    # masterpieces are foil only, the rest both ways
    assert_search_equal "booster:akh-draft", "(e:akh is:baseset) or (e:mp2 cn:1-30)"
    assert_search_equal "booster-nonfoil:akh-draft", "(e:akh is:baseset)"
    assert_search_equal "booster-foil:akh-draft", "(e:akh is:baseset) or (e:mp2 cn:1-30)"
    # star queries respect foiling too
    assert_search_results "booster-foil:* e:lea"
    assert_search_equal "booster-nonfoil:* e:akh", "booster-nonfoil:akh-* e:akh"
  end
end

# Every db here iterates the whole booster index, most of which names sets a
# subset doesn't have. Those boosters are skipped, they aren't an error.
describe "booster index" do
  include_context "db"

  # PackFactory skips boosters whose set it can't resolve, which is how subset
  # databases work at all. On the full db that would hide a typo, so check here
  it "only names sets we have" do
    booster_codes = JSON.parse(CardDatabase::BOOSTER_INDEX_PATH.read).keys
    set_codes = booster_codes.map{|code| code.split("-", 2).first}.uniq
    set_codes.reject{|set_code| db.resolve_edition(set_code)}.should eq([])
  end
end

describe "booster: on a subset database" do
  include_context "db", "mrd", "arn"

  it "supports regular queries" do
    assert_search_equal "booster:mrd", "e:mrd"
  end

  it "only knows the boosters of the sets it has" do
    db.supported_booster_types.keys.should eq(
      ["mrd", "mrd-draft", "mrd-fat-pack", "mrd-tournament", "arn"]
    )
    db.most_recent_booster_type.should eq("mrd-draft")
  end
end

describe "boosters on a subset database with none" do
  include_context "db", "cmd"

  it "has no booster types" do
    db.supported_booster_types.should eq({})
    db.most_recent_booster_type.should eq(nil)
  end
end
