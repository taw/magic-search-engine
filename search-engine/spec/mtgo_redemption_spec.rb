describe MtgoRedemption do
  include_context "db"

  let(:redemption) { MtgoRedemption.new }

  # Warning only, as this needs someone to go read https://www.mtgo.com/news/
  # and update data/mtgo_redemption.csv or data/mtgo_not_redeemable.yaml.
  # Sets which aren't out yet are skipped, as nobody announced them either.
  it "every Standard-legal set is known to be redeemable on MTGO or not" do
    warning = redemption.missing_redemptions_warning(db)
    warn warning if warning
  end

  it "data files agree with each other" do
    (redemption.set_codes & redemption.not_redeemable.keys).should eq([])
  end

  it "data files only list sets that exist" do
    (redemption.set_codes + redemption.not_redeemable.keys).reject{|code| db.sets[code]}.should eq([])
  end

  it "every not redeemable set says where we know it from" do
    redemption.not_redeemable.reject{|code, source| source.to_s =~ /\S/}.should eq({})
  end
end
