# Sealed is the pool builder behind bin/open_packs and bin/open_packs_json.
# Nothing on the site goes through it, so these specs are the only thing
# pinning its descriptor grammar.
describe Sealed do
  include_context "db"

  def names(*descriptors)
    Sealed.new(db, *descriptors).call.map(&:name)
  end

  def size(*descriptors)
    Sealed.new(db, *descriptors).call.size
  end

  it "adds a single card" do
    names("mrd/1").should eq ["Altar's Light"]
  end

  it "adds a card multiple times" do
    names("2x mrd/1").should eq ["Altar's Light", "Altar's Light"]
  end

  it "adds a foil card multiple times" do
    Sealed.new(db, "2x m19/306/foil").call.map{|c| [c.name, c.foil]}.should eq(
      [["Nexus of Fate", true], ["Nexus of Fate", true]]
    )
  end

  # The whole reason the count needs a separator: without one this is either
  # two copies of card 100 of set `2`, or one copy of 2X2's card 100
  it "reads a set code that starts with a digit as a set code" do
    names("2x2/100").should eq ["Abbot of Keral Keep"]
    names("10e/1").should eq ["Ancestor's Chosen"]
  end

  it "opens a pack" do
    size("nph").should eq 15
  end

  # A bare set code means that set's default booster, which only
  # CardDatabase#supported_booster_types knows how to resolve
  it "resolves a bare set code to its default booster" do
    Sealed.new(db, "nph").call.map(&:set_code).uniq.should eq ["nph"]
  end

  it "opens a variant pack" do
    size("iko-collector").should eq 15
  end

  it "opens a pack multiple times" do
    size("6x m10").should eq 90
    size("6 m10").should eq 90
  end

  it "combines packs and cards" do
    size("36x mh1", "mh1/255").should eq 541
  end

  it "rejects a count with no separator" do
    proc{ size("6xm10") }.should raise_error(/No pack for 6xm10/)
    proc{ size("2xmrd/1") }.should raise_error(/Can't find set 2xmrd/)
  end

  it "rejects things it cannot open" do
    proc{ size("lolwtf") }.should raise_error(/No pack for lolwtf/)
    proc{ size("mrd/lolwtf") }.should raise_error(%r[Can't find card mrd/lolwtf])
  end
end
