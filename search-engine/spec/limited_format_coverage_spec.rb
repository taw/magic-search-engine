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
