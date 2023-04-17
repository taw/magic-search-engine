describe "Time Spiral block" do
  include_context "db", "tsp", "tsb", "plc", "fut"

  it "is:future" do
    assert_search_include "is:future", "Dryad Arbor"
    assert_search_exclude "is:new", "Dryad Arbor"
    assert_search_exclude "is:old", "Dryad Arbor"
    assert_search_results "is:future is:vanilla",
      "Blade of the Sixth Pride",
      "Blind Phantasm",
      "Fomori Nomad",
      "Mass of Ghouls",
      "Nessian Courser"
      # "Dryad Arbor" # used to be here, but no more
  end

  it "is:new" do
    assert_search_exclude "is:future", "Amrou Scout"
    assert_search_include "is:new", "Amrou Scout"
    assert_search_exclude "is:old", "Amrou Scout"
  end

  it "is:old" do
    assert_search_exclude "is:future", "Squire"
    assert_search_exclude "is:new", "Squire"
    assert_search_include "is:old", "Squire"
  end

  it "is:*-bordered" do
    "is:black-bordered" .should include_cards "Dryad Arbor"
    "is:white-bordered" .should return_no_cards "Dryad Arbor"
    "is:silver-bordered".should return_no_cards "Dryad Arbor"
  end

  it "Dryad Arbor" do
    assert_search_include "c:g", "Dryad Arbor"
    assert_search_exclude "c:c", "Dryad Arbor"
    assert_search_include "is:permanent", "Dryad Arbor"
    assert_search_exclude "is:spell", "Dryad Arbor"
    assert_search_results "t:land t:creature", "Dryad Arbor"
  end

  it "Ghostfire" do
    assert_search_exclude "c:r", "Ghostfire"
    assert_search_include "ci:r", "Ghostfire"
    assert_search_include "c:c", "Ghostfire"
  end

  it "Non-ASCII" do
    assert_search_results "Dralnu", "Dralnu, Lich Lord"
    assert_search_results "Dralnu Lich Lord", "Dralnu, Lich Lord"
    assert_search_results "Dralnu, Lich Lord", "Dralnu, Lich Lord"
    assert_search_results "Dralnu , Lich Lord", "Dralnu, Lich Lord"
    assert_search_results "Dandân", "Dandân"
    assert_search_results "Dandan", "Dandân"
    assert_search_results "Cutthroat il-Dal", "Cutthroat il-Dal"
    assert_search_results "Cutthroat il Dal", "Cutthroat il-Dal"
    assert_search_results "Cutthroat ildal", "Cutthroat il-Dal" # Thanks to spelling corrections
    assert_search_results "Lim-Dûl the Necromancer", "Lim-Dûl the Necromancer"
    assert_search_results "Lim-Dul the Necromancer", "Lim-Dûl the Necromancer"
    assert_search_results "Lim Dul the Necromancer", "Lim-Dûl the Necromancer"
    assert_search_results "Limdul the Necromancer", "Lim-Dûl the Necromancer"
    assert_search_results "limdul necromancer", "Lim-Dûl the Necromancer"
    assert_search_results "lim dul necromancer", "Lim-Dûl the Necromancer"
    assert_search_results "lim dul necromancer", "Lim-Dûl the Necromancer"
    assert_search_results "Sarpadian Empires, Vol. VII", "Sarpadian Empires, Vol. VII"
    assert_search_results "sarpadian empires vol vii", "Sarpadian Empires, Vol. VII"
    assert_search_results "sarpadian empires", "Sarpadian Empires, Vol. VII"
  end

  it "is: opposes not:" do
    assert_search_equal "not:future", "-is:future"
    assert_search_equal "not:new", "-is:new"
    assert_search_equal "not:old", "-is:old"
  end

  it "is:colorshifted" do
    assert_count_printings "is:colorshifted", 45
  end

  it "is:timeshifted" do
    assert_count_printings "is:timeshifted", 122 + 81 # TSTS + FUT
  end

  it "manaless suspend cards" do
    assert_search_results "cmc=0 o:suspend", "Ancestral Vision", "Hypergenesis", "Living End", "Lotus Bloom", "Restore Balance", "Wheel of Fate"
    assert_search_results "cmc=0 o:suspend ci:c", "Lotus Bloom"
    assert_search_results "cmc=0 o:suspend ci:u", "Lotus Bloom", "Ancestral Vision"
    assert_search_results "cmc=0 o:suspend c:c", "Lotus Bloom"
    assert_search_results "cmc=0 o:suspend c:u", "Ancestral Vision"
    assert_search_results "cmc=0 o:suspend mana=0"
  end

  # This goes against magiccards.info logic which treats * as 0
  # I'm not sure yet if it makes any sense or not
  it "lhurgoyfs" do
    assert_search_results "t:lhurgoyf", "Tarmogoyf", "Detritivore"
    assert_search_results "t:lhurgoyf pow=0"
    assert_search_results "t:lhurgoyf tou=0"
    assert_search_results "t:lhurgoyf tou=1"
    assert_search_results "t:lhurgoyf pow>=0"
    assert_search_results "t:lhurgoyf tou>=0"
    assert_search_results "t:lhurgoyf pow<tou", "Tarmogoyf"
    assert_search_results "t:lhurgoyf pow<=tou", "Tarmogoyf", "Detritivore"
    assert_search_results "t:lhurgoyf pow>=tou", "Detritivore"
    assert_search_results "t:lhurgoyf pow=tou", "Detritivore"
    assert_search_results "t:lhurgoyf pow>tou"
  end

  it "negative" do
    assert_search_results "pow=-1", "Char-Rumbler"
    assert_search_results "pow<0", "Char-Rumbler"
    assert_search_include "pow>=-1", "Char-Rumbler"
    assert_search_include "pow>=-2", "Char-Rumbler"
    assert_search_exclude "pow>-1", "Char-Rumbler"
  end

  it "oracle unicode" do
    assert_search_results %[ft:"Lim-Dûl"], "Drudge Reavers"
    assert_search_results %[ft:"Lim-Dul"], "Drudge Reavers"
  end

  # MCI/v3 is:timeshifted is SF/v4+ is:colorshifted
  # we now use new mtgjson definition
  it "is:colorshifted" do
    assert_search_equal "is:colorshifted", "frame:colorshifted"
  end
end
