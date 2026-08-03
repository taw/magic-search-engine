require_relative "limited_format_coverage"

describe LimitedFormatCoverage do
  include_context "db"

  let(:coverage) { LimitedFormatCoverage.new(db) }

  # Warning only, as filling a format in needs someone to go find out what the
  # event actually was, and new sets get their boosters long before that.
  it "every set with the boosters for a format has that format" do
    warning = coverage.missing_formats_warning
    warn warning if warning
  end

  # Warnings too, as a set which really did skip its own boosters, or a
  # prerelease booster nobody was handed, is something to go look up, not
  # something to fail CI over.
  it "every draft opens boosters of its own set" do
    warning = coverage.drafts_without_own_boosters_warning
    warn warning if warning
  end

  it "every prerelease booster is handed out by some prerelease pool" do
    warning = coverage.unused_prerelease_boosters_warning
    warn warning if warning
  end

  # Magic Online only sets were drafted there, and had no paper events at all
  it "expects an mtgo draft and nothing else from a Magic Online only set" do
    coverage.expected_formats.select{|set_code, format| set_code == "me1"}
      .should eq([["me1", "mtgo-draft"]])
    coverage.expected_formats.select{|set_code, format| format == "mtgo-draft"}
      .map(&:first).should match_array(["me1", "me2", "me3", "me4", "vma", "tpr"])
  end

  # An Arena set which was also printed on paper has both drafts, an Arena only
  # one has just the Arena draft, and no sealed either way
  it "expects an arena draft from a set with Arena boosters" do
    coverage.expected_formats.select{|set_code, format| set_code == "dom"}
      .should match_array([["dom", "draft"], ["dom", "sealed"], ["dom", "prerelease-sealed"], ["dom", "arena-draft"]])
    coverage.expected_formats.select{|set_code, format| set_code == "akr"}
      .should eq([["akr", "arena-draft"]])
    # Play Booster sets have their Arena booster named after it
    coverage.expected_formats.should include(["mkm", "arena-draft"])
  end

  # Sets whose Arena boosters rotated were drafted once per booster
  it "expects one numbered arena draft per numbered arena booster" do
    coverage.expected_formats.select{|set_code, format| set_code == "sir"}
      .should eq([["sir", "arena-draft-1"], ["sir", "arena-draft-2"], ["sir", "arena-draft-3"], ["sir", "arena-draft-4"]])
    coverage.expected_formats.select{|set_code, format| set_code == "pio"}
      .should eq([["pio", "arena-draft-1"], ["pio", "arena-draft-2"], ["pio", "arena-draft-3"]])
  end

  it "data file only lists sets that exist" do
    coverage.not_played.keys.reject{|set_code| db.sets[set_code]}.should eq([])
  end

  it "data file only lists formats we'd otherwise expect" do
    expected = coverage.expected_formats.to_set
    listed = coverage.not_played.flat_map{|set_code, formats| formats.keys.map{|format| [set_code, format]}}
    listed.reject{|entry| expected.include?(entry)}.should eq([])
  end

  it "data file has no entries for formats a set does have" do
    coverage.stale_not_played.should eq([])
  end

  it "every entry says why the format never happened" do
    coverage.not_played.each do |set_code, formats|
      formats.each do |format, reason|
        reason.to_s.should match(/\S/), "#{set_code} #{format} needs a reason"
      end
    end
  end
end
