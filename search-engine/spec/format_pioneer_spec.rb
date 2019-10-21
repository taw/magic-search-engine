describe "Formats - Pioneer" do
  include_context "db"

  let(:regular_sets) do
    db.sets.values.select{|s|
      s.types.include?("core") or s.types.include?("expansion") or s.name =~ /Welcome Deck/
    }.to_set
  end

  describe "Pioneer legal sets" do
    let(:start_date) { db.sets["rtr"].release_date }
    let(:expected) { regular_sets.select{|set| set.release_date >= start_date}.map(&:code).to_set }
    let(:actual) { FormatPioneer.new.included_sets }
    it { expected.should eq actual }
  end

  it do
    assert_block_composition "Pioneer", "eld", ["rtr", "gtc", "dgm", "m14", "ths", "bng", "jou", "m15", "ktk", "frf", "dtk", "ori", "bfz", "ogw", "soi", "w16", "emn", "kld", "aer", "akh", "w17", "hou", "xln", "rix", "dom", "m19", "grn", "rna", "war", "m20", "eld"],
      "Bloodstained Mire" => "banned",
      "Flooded Strand" => "banned",
      "Polluted Delta" => "banned",
      "Windswept Heath" => "banned",
      "Wooded Foothills" => "banned"
  end
end

