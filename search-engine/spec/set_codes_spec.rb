describe "Set Codes" do
  include_context "db"

  it "full_name" do
    db.sets.values.each do |set|
      assert_resolves set.name, set
    end
  end

  it "mci_code" do
    db.sets.values.each do |set|
      assert_resolves set.code, set
    end
  end

  it "alternative_code" do
    db.sets.values.each do |set|
      next unless set.alternative_code
      assert_resolves set.alternative_code, set
    end
  end

  def assert_resolves(query, *sets)
    sets.map(&:name).to_set.should eq(db.resolve_editions(query).map(&:name).to_set)
  end
end
