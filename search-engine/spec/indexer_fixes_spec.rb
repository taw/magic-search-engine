describe "Indexer Fixes Test" do
  include_context "db"

  it "rqs" do
    %W[basic common uncommon rare].each do |rarity|
      (search_names("e:rqs r:#{rarity}") - search_names("e:4e r:#{rarity}")).should be_empty
    end
    search("e:rqs -r:rare -r:uncommon -r:common -r:basic").should be_empty
  end

  it "itp" do
    %W[basic common uncommon rare].each do |rarity|
      (search_names("e:rqs r:#{rarity}") - search_names("e:4e r:#{rarity}")).should be_empty
    end
    search("e:itp -r:rare -r:uncommon -r:common -r:basic").should be_empty
  end

  it "Clash packs" do
    search("e:clash").size.should eq 18
    search("e:clash r:special").should be_empty
    search("e:clash r:common").size.should eq 1
    search("e:clash r:uncommon").size.should eq 3
    search("e:clash r:rare").size.should eq 14
  end

  it "Coldsnap Theme Decks" do
    (search("e:cstd -r:uncommon -r:common -r:basic")).should be_empty

    assert_search_results "e:cstd r:common",
      "Aurochs",
      "Barbed Sextant",
      "Brainstorm",
      "Casting of Bones",
      "Dark Banishing",
      "Dark Ritual",
      "Deadly Insect",
      "Disenchant",
      "Essence Flare",
      "Gangrenous Zombies",
      "Gorilla Shaman",
      "Incinerate",
      "Insidious Bookworms",
      "Kjeldoran Dead",
      "Kjeldoran Pride",
      "Lat-Nam's Legacy",
      "Legions of Lim-Dûl",
      "Mistfolk",
      "Orcish Lumberjack",
      "Phantasmal Fiend",
      "Portent",
      "Reinforcements",
      "Snow Devil",
      "Soul Burn",
      "Tinder Wall",
      "Woolly Mammoths",
      "Zuran Spellcaster"

    assert_search_results "e:cstd r:uncommon",
      "Arcum's Weathervane",
      "Ashen Ghoul",
      "Balduvian Dead",
      "Binding Grasp",
      "Bounty of the Hunt",
      "Browse",
      "Death Spark",
      "Drift of the Dead",
      "Giant Trap Door Spider",
      "Iceberg",
      "Kjeldoran Elite Guard",
      "Kjeldoran Home Guard",
      "Orcish Healer",
      "Scars of the Veteran",
      "Skull Catapult",
      "Storm Elemental",
      "Swords to Plowshares",
      "Viscerid Drone",
      "Whalebone Glider",
      "Wings of Aesthir"

    assert_search_results "e:cstd r:basic",
      "Forest",
      "Island",
      "Mountain",
      "Plains",
      "Swamp"
  end

  it "No unknown artists" do
    assert_search_results %[a:"?"]
  end

  # Some old issues fixed since then, but extra regression tests won't hurt
  it "No Ae ligature in card names" do
    db.cards.values.map(&:name).grep(/Æ/i).should be_empty
  end

  it "No &amp; in artist names" do
    db.printings.map(&:artist_name).grep(/&amp/).should be_empty
  end

  context "foreign names" do
    # Same as the indexer, and SP//dr is not a split card
    def split_card_name(name)
      parts = name.split(%r{ // |/}, -1)
      parts if parts.size > 1 and parts.none?(&:empty?)
    end

    def foreign_names_where
      result = []
      db.cards.each_value do |card|
        card.foreign_names.each do |language, names|
          names = [*names]
          names.each do |name|
            result << [card.name, language, name] if yield(name, names, card)
          end
        end
      end
      result
    end

    it "No English names of split cards" do
      english_names = Set[*db.cards.each_value.map(&:name)]
      foreign_names_where{|name, _|
        split_card_name(name)&.all?{|part| english_names.include?(part)}
      }.should eq []
    end

    it "No both halves of split cards" do
      foreign_names_where{|name, _| split_card_name(name)}.should eq []
    end

    it "No English names when we have an actual translation" do
      foreign_names_where{|name, names, card|
        names.size > 1 and name.tr("“”", %[""]) == card.name
      }.should eq []
    end

    it "No furigana in Japanese names" do
      foreign_names_where{|name, _| name =~ /[（）]/}.should eq []
    end

    it "Split cards get just their own half" do
      db.cards["warden"].foreign_names[:de].should eq "Vollstrecker"
      db.cards["find"].foreign_names[:sp].should eq "Descubrir"
      db.cards["dawn"].foreign_names[:cs].should eq "朝生"
      db.cards["supply"].foreign_names[:it].should eq "Offerta"
      db.cards["replicate"].foreign_names[:cs].should eq "复造"
    end

    it "Split cards we only have both halves of get their half by position" do
      db.cards["cease"].foreign_names[:sp].should eq "Cese"
      db.cards["desist"].foreign_names[:sp].should eq "Desista"
      db.cards["push"].foreign_names[:fr].should eq "Pousser"
      db.cards["pull"].foreign_names[:fr].should eq "Tirer"
      db.cards["supply"].foreign_names[:fr].should eq "Offre"
      db.cards["fuss"].foreign_names[:de].should eq "Gesums"
      db.cards["bother"].foreign_names[:de].should eq "Gedöns"
      db.cards["wax"].foreign_names[:jp].should eq "増進"
    end

    it "SP//dr is not a split card" do
      db.cards["sp//dr, piloted by peni"].foreign_names[:it].should eq "SP//dr, Aracnomecha"
    end

    it "Japanese names have no furigana" do
      db.cards["aftermath analyst"].foreign_names[:jp].should eq "事件現場の分析者"
      db.cards["rakdos, the muscle"].foreign_names[:jp].should eq "用心棒、ラクドス"
    end

    it "French names use œ but not æ" do
      db.cards["rancor"].foreign_names[:fr].should eq "Rancœur"
      db.cards["dingus egg"].foreign_names[:fr].should eq "Œuf de dingus"
      db.cards["faerie mastermind"].foreign_names[:fr].should eq "Érudit faerie"
      db.cards["cloud of faeries"].foreign_names[:fr].should eq "Nuée de faeries"
    end

    it "English names with fancy quotes are still English names" do
      db.cards[%[kongming, "sleeping dragon"]].foreign_names[:cs].should eq "卧龙先生诸葛亮"
    end

    it "No rules text instead of names on TDM omens" do
      db.cards["absorb essence"].foreign_names[:fr].should eq "Absorption d'essence"
      db.cards["flush out"].foreign_names[:fr].should eq "Purge"
      db.cards["dusk sight"].foreign_names[:fr].should eq "Vision crépusculaire"
      # Which is a real card name, just not of these
      db.cards["flight"].foreign_names[:fr].should eq "Vol"
    end
  end
end
