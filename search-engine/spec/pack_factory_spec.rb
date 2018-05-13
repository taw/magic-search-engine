describe PackFactory do
  include_context "db"
  let(:factory) { PackFactory.new(db) }

  it "Only sets of appropriate types have sealed packs" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      # Indexer responsibility to set this flag
      if set.has_boosters?
        pack = factory.for(set_code)
        if pack
          pack.should be_a(Pack), "#{set_pp} should have packs"
        else
          # TODO: pending
        end
      else
        pack.should eq(nil), "#{set_pp} should not have packs"
      end
    end
  end

  it "Every card can appear in a pack" do
    db.sets.each do |set_code, set|
      # Some sets don't follow these rules
      # They should have own tests
      next if %W[dgm uh jou frf].include?(set_code)
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      pack = factory.for(set_code)
      next unless pack
      pack.nonfoil_cards.should match_array(set.physical_cards_in_boosters),
        "All cards in #{set_pp} should be possible in its packs as nonfoil"
    end
  end

  it "Every set with foils has all cards available as foils" do
    db.sets.each do |set_code, set|
      set_pp = "#{set.name} [#{set.code}/#{set.type}]"
      pack = factory.for(set_code)
      next unless pack
      next unless pack.has_foils?
      actual_cards = pack.foil_cards.select{|c| c.set.type != "masterpiece"}
      expected_cards = set.physical_cards_in_boosters(true)
      actual_cards.should match_array(expected_cards),
        "All cards in #{set_pp} should be possible in its packs as foil"
    end
  end

  context "Dragon's Maze" do
    let(:pack) { factory.for("dgm") }
    let(:ev) { pack.expected_values }
    let(:maze_end) { physical_card("e:dgm maze end", foil) }
    let(:guildgate) { physical_card("e:dgm azorius guildgate", foil) }
    let(:common) { physical_card("e:dgm azorius cluestone", foil) }
    let(:uncommon) { physical_card("e:dgm alive // well", foil) }
    let(:rare) { physical_card("e:dgm advent of the wurm", foil) }
    let(:mythic) { physical_card("e:dgm progenitor mimic", foil) }
    let(:shockland) { physical_card("e:rtr temple garden", foil) }

    context "normal" do
      let(:foil) { false }

      it do
        ev[guildgate].should eq Rational(23, 242)
        ev[maze_end].should eq Rational(2, 242)
        ev[shockland].should eq Rational(1, 242)
        # 9.75 commons per pack, since 25% of packs have foil instead
        ev[common].should eq Rational(975, 100) * Rational(1, 60)
        ev[uncommon].should eq Rational(3, 40)
        ev[rare].should eq Rational(1, 40)
        ev[mythic].should eq Rational(1, 80)
      end
    end

    context "foil" do
      let(:foil) { true }

      it do
        # Definitely no shocklands
        ev[shockland].should eq 0

        # This is all pure guesswork
        # - base rarity rates on foils are guesses
        # - assumption that foiling treats maze's end and guildgates like regular cards is a guess
        # Perhaps it's wrong, and we should instead assume land slot works like basic foils?s
        ev[guildgate].should eq Rational(1,4) * Rational(5,8) * Rational(1,70)
        ev[common].should eq Rational(1,4) * Rational(5,8) * Rational(1,70)
        ev[uncommon].should eq Rational(1,4) * Rational(2,8) * Rational(1,40)
        ev[rare].should eq Rational(1,4) * Rational(1,8) * Rational(2,81)
        ev[mythic].should eq Rational(1,4) * Rational(1,8) * Rational(1,81)
        ev[maze_end].should eq Rational(1,4) * Rational(1,8) * Rational(1,81)
      end
    end
  end

  context "Unhinged" do
    let(:pack) { factory.for("uh") }
    let(:ev) { pack.expected_values }
    let(:basic) { physical_card("e:uh forest", foil) }
    let(:common) { physical_card("e:uh awol", foil) }
    let(:uncommon) { physical_card("e:uh cheatyface", foil) }
    let(:rare) { physical_card("e:uh ambiguity", foil) }
    let(:super_secret_tech) { physical_card("e:uh super secret tech", foil) }

    context "normal" do
      let(:foil) { false }
      it do
        ev[basic].should eq Rational(1,5)
        ev[common].should eq Rational(975,100) * Rational(1,55)
        ev[uncommon].should eq Rational(3,40)
        ev[rare].should eq Rational(1,40)
        ev[super_secret_tech].should eq 0
      end
    end

    context "foil" do
      let(:foil) { true }
      it do
        ev[basic].should eq Rational(1,4) * Rational(1,8) * Rational(1,5)
        ev[common].should eq Rational(1,4) * Rational(4,8) * Rational(1,55)
        ev[uncommon].should eq Rational(1,4) * Rational(2,8) * Rational(1,40)
        ev[rare].should eq Rational(1,4) * Rational(1,8) * Rational(1,41)
        ev[super_secret_tech].should eq Rational(1,4) * Rational(1,8) * Rational(1,41)
      end
    end
  end
end
