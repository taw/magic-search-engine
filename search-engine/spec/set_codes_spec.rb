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

  # Arena has no code for an individual Alchemy set: they all go under one
  # pseudo-set per Arena year, so the mapping is a table, and these are the
  # invariants that keep it honest. A new Alchemy set fails "cover every
  # Alchemy set" until it is added to CardDatabase::ARENA_ALCHEMY_YEARS.
  it "arena_alchemy_year_code" do
    CardDatabase::ARENA_ALCHEMY_YEARS.each do |arena_code, set_codes|
      assert_resolves arena_code, *set_codes.map{|set_code| db.sets[set_code]}
      # An Arena year starts when the first of its Alchemy sets comes out.
      # Without this, resolving several sets is what "ambiguous" means to
      # resolve_time and it would raise.
      db.resolve_time(arena_code).should eq(set_codes.map{|set_code| db.sets[set_code].release_date}.min)
    end
  end

  it "arena alchemy years cover every Alchemy set exactly once" do
    # hbg, om1 and omb are Alchemy sets too, but each has its own Arena code
    alchemy_sets = db.sets.values.select{|set| set.types.include?("alchemy") and set.code.start_with?("y")}
    listed = CardDatabase::ARENA_ALCHEMY_YEARS.values.flatten
    listed.tally.select{|_, count| count > 1}.should eq({})
    listed.sort.should eq(alchemy_sets.map(&:code).sort)
  end

  # An Arena year is not a calendar year - Alchemy: Innistrad is Y22 and came
  # out in December 2021 - but it does end in the year it is named after, and
  # one year's sets are all released before the next year's.
  it "arena alchemy year is the calendar year of its last set" do
    years = CardDatabase::ARENA_ALCHEMY_YEARS.map do |arena_code, set_codes|
      dates = set_codes.map{|set_code| db.sets[set_code].release_date}
      dates.max.year.should eq(2000 + arena_code.delete_prefix("y").to_i)
      dates.minmax
    end
    years.each_cons(2) do |(_, previous_last), (next_first, _)|
      previous_last.should be < next_first
    end
  end

  # Arena's years are almost the Alchemy rotation calendar: every Alchemy set
  # belongs to the rotation window it was released in, except that the Alchemy
  # set of whichever release triggers a rotation comes out a few weeks after it
  # and stays with the outgoing year. Alchemy: Edge of Eternities is the only
  # one so far. This is not a rule we can derive the table from, but a second
  # exception showing up is worth a look rather than a silent table edit.
  it "arena alchemy years follow the Alchemy rotation calendar" do
    rotations = FormatAlchemy::ROTATION_SCHEDULE.map(&:first).sort
    trails_its_rotation = %W[yeoe]

    CardDatabase::ARENA_ALCHEMY_YEARS.each do |arena_code, set_codes|
      (set_codes - trails_its_rotation).each do |set_code|
        window_index = rotations.rindex{|rotation| rotation <= db.sets[set_code].release_date}
        "y#{22 + window_index}".should eq(arena_code)
      end
    end
  end

  def assert_resolves(query, *sets)
    sets.map(&:name).to_set.should eq(db.resolve_editions(query).map(&:name).to_set)
  end
end
