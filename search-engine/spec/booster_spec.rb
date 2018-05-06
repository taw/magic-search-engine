describe "is:booster" do
  include_context "db"

  it "set has boosters" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      should_have_boosters = (
        %W[expansion core un reprint conspiracy masters starter].include?(set.type) and
        !%W[ced cedi tsts itp st2k cp1 cp2 cp3 w16 w17].include?(set.code)
      )
      if should_have_boosters
        set.should have_boosters, "#{set_pp} should have boosters"
      else
        set.should_not have_boosters, "#{set_pp} should not have boosters"
      end
    end
  end

  it "card is in boosters" do
    # TODO
  end
end
