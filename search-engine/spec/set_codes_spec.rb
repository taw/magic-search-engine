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

  # Arena's codes go into the same alternative_code slot as the mci ones.
  # Arena also lumps every Alchemy set into Y22..Y26, and one code per set can't express that.
  it "arena_code" do
    {
      "dar" => "dom",
      "aha1" => "ha1",
      "aha2" => "ha2",
      "aha3" => "ha3",
      "aha4" => "ha4",
      "aha5" => "ha5",
      "aha6" => "ha6",
      "aha7" => "ha7",
    }.each do |arena_code, set_code|
      set = db.sets[set_code]
      set.alternative_code.should eq(arena_code)
      # "dar" alone would name-match The Dark and Darksteel
      assert_resolves arena_code, set
    end
  end

  def assert_resolves(query, *sets)
    sets.map(&:name).to_set.should eq(db.resolve_editions(query).map(&:name).to_set)
  end
end
