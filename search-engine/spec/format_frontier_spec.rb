# The fdormat looks completely dead

# describe "Formats - Frontier" do
#   include_context "db"

#   let(:regular_sets) do
#     db.sets.values.select{|s|
#       s.types.include?("core") or s.types.include?("expansion") or s.name =~ /Welcome Deck/ or s.name =~ /M19 Gift Pack/
#     }.to_set
#   end

#   describe "Frontier legal sets" do
#     let(:start_date) { db.sets["m15"].release_date }
#     let(:expected) { regular_sets.select{|set| set.release_date >= start_date}.map(&:code).to_set }
#     let(:actual) { FormatFrontier.new.included_sets }
#     it { expected.should eq actual }
#   end

#   it "frontier" do
#     assert_block_composition "frontier", "eld", [
#       "m15",
#       "ktk",
#       "frf",
#       "dtk",
#       "ori",
#       "bfz",
#       "ogw",
#       "soi",
#       "w16",
#       "emn",
#       "kld",
#       "aer",
#       "akh",
#       "w17",
#       "hou",
#       "xln",
#       "rix",
#       "dom",
#       "m19",
#       "g18",
#       "grn",
#       "rna",
#       "war",
#       "m20",
#       "eld",
#     ]
#   end
# end
