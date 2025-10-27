describe "Indexer hacks" do
  include_context "db"
  let(:index_path) { Pathname(__dir__) + "../../index/index.json" }
  let(:index_json) { index_path.read }

  it "W16 release date" do
    db.sets["w16"].release_date.should eq Date.parse("2016-04-08")
  end

  # We pretty much write whole card in indexer
  it "B.F.M. (Big Furry Monster)" do
    bfms = db.search("Big Furry Monster").printings
    bfms.size.should eq(2)
    bfms[0].name.should eq("B.F.M. (Big Furry Monster)")
    bfms[1].name.should eq("B.F.M. (Big Furry Monster, Right Side)")
    bfms.each do |bfm|
      bfm.names.should eq(["B.F.M. (Big Furry Monster)", "B.F.M. (Big Furry Monster, Right Side)"])
      bfm.layout.should eq("normal")
      bfm.colors.should eq("b")
      bfm.text.should eq("You must play both B.F.M. cards to put B.F.M. into play. If either B.F.M. card leaves play, sacrifice the other.\nB.F.M. can be blocked only by three or more creatures.")
      bfm.funny.should eq(true)
      bfm.mana_cost.should eq("{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}{b}")
      bfm.types.should eq(["creature", "the-biggest-baddest-nastiest-scariest-creature-you'll-ever-see"])
      bfm.cmc.should eq(15)
      bfm.power.should eq(99)
      bfm.toughness.should eq(99)
      bfm.card.color_identity.should eq("b")
      bfm.typeline.should eq("Creature - The-Biggest-Baddest-Nastiest-Scariest-Creature-You'll-Ever-See")
      bfm.color_identity.should eq("b")
      bfm.flavor.should eq("\"It was big. Really, really big. No, bigger than that. Even bigger. Keep going. More. No, more. Look, we're talking krakens and dreadnoughts for jewelry. It was big\"\n-Arna Kennerd, skyknight")
    end
  end

  # This got complicated enough that I'm not sure it's worth maintaining
  it "is:funny" do
    # mb2 is complicated, so skip it
    # Also don't even bother with Arena and Shandalar cards
    assert_search_equal_cards "is:funny -e:mb2 -game:arena -game:shandalar", "(e:unh,ugl,uqc,hho,ust,pust,ppc1,h17,tbth,tdag,tfth,thp1,thp2,thp3,ptg,cmb1,cmb2,und,punh,ulst,unf,phtr,ph17,ph18,ph19,ph20,ph21,ph22,unk,punk -(t:basic -Barry) -(Steamflogger Boss) -(Hall of Triumph) -(Zur the Enchanter) -is:shockland -(e:unf -is:acorn)) or (e:sld is:heart) or (e:pf25 Second City) or (e:pf24 Convention Maro) -game:arena -game:shandalar or (e:pf25 Spaghetti Junction) or (e:pf25 All-You-Can-Eat Buffet)"
  end

  it "Nissa's X loyallty" do
    nissa = db.search("!Nissa, Steward of Elements").printings[0]
    nissa.loyalty.should eq("X")
  end

  it "meld card numbers" do
    # There's a lot of weird logic for meld cards
    db.search("is:meld").printings.map{|c| [c.set_code, c.name, c.number]}.should match_array([
      ["bro", "Argoth, Sanctum of Nature", "256"],
      ["bro", "Mishra, Claimed by Gix", "216"],
      ["bro", "Mishra, Lost to Phyrexia", "163b"],
      ["bro", "Phyrexian Dragon Engine", "163"],
      ["bro", "The Mightstone and Weakstone", "238"],
      ["bro", "Titania, Gaea Incarnate", "256b"],
      ["bro", "Titania, Voice of Gaea", "193"],
      ["bro", "Urza, Lord Protector", "225"],
      ["bro", "Urza, Planeswalker", "238b"],
      ["emn", "Brisela, Voice of Nightmares", "15b"],
      ["emn", "Bruna, the Fading Light", "15"],
      ["emn", "Chittering Host", "96b"],
      ["emn", "Gisela, the Broken Blade", "28"],
      ["emn", "Graf Rats", "91"],
      ["emn", "Hanweir Battlements", "204"],
      ["emn", "Hanweir Garrison", "130"],
      ["emn", "Hanweir, the Writhing Township", "130b"],
      ["emn", "Midnight Scavengers", "96"],
      ["inr", "Brisela, Voice of Nightmares", "14b"],
      ["inr", "Bruna, the Fading Light", "14"],
      ["inr", "Chittering Host", "123b"],
      ["inr", "Gisela, the Broken Blade", "24"],
      ["inr", "Graf Rats", "113"],
      ["inr", "Hanweir Battlements", "279"],
      ["inr", "Hanweir Garrison", "157"],
      ["inr", "Hanweir, the Writhing Township", "157b"],
      ["inr", "Midnight Scavengers", "123"],
      ["pbro", "Argoth, Sanctum of Nature", "256s"],
      ["pbro", "Mishra, Claimed by Gix", "216s"],
      ["pbro", "Mishra, Lost to Phyrexia", "163bs"],
      ["pbro", "Phyrexian Dragon Engine", "163s"],
      ["pbro", "The Mightstone and Weakstone", "238s"],
      ["pbro", "Titania, Gaea Incarnate", "256bs"],
      ["pbro", "Titania, Voice of Gaea", "193s"],
      ["pbro", "Urza, Lord Protector", "225s"],
      ["pbro", "Urza, Planeswalker", "238bs"],
      ["pemn", "Brisela, Voice of Nightmares", "15bs"],
      ["pemn", "Bruna, the Fading Light", "15s"],
      ["pemn", "Gisela, the Broken Blade", "28s"],
      ["pemn", "Hanweir Battlements", "204s"],
      ["pemn", "Hanweir Garrison", "130s"],
      ["pemn", "Hanweir, the Writhing Township", "130bs"],
      ["sir", "Brisela, Voice of Nightmares", "17b"],
      ["sir", "Bruna, the Fading Light", "17"],
      ["sir", "Chittering Host", "115b"],
      ["sir", "Gisela, the Broken Blade", "30"],
      ["sir", "Graf Rats", "115"],
      ["sir", "Hanweir Battlements", "271"],
      ["sir", "Hanweir Garrison", "161"],
      ["sir", "Hanweir, the Writhing Township", "161b"],
      ["sir", "Midnight Scavengers", "123"],
      ["sld", "Brisela, Voice of Nightmares", "1336b"],
      ["sld", "Brisela, Voice of Nightmares", "1388b"],
      ["sld", "Bruna, the Fading Light", "1336"],
      ["sld", "Bruna, the Fading Light", "1388"],
      ["sld", "Gisela, the Broken Blade", "1335"],
      ["sld", "Gisela, the Broken Blade", "1387"],
      ["v17", "Brisela, Voice of Nightmares", "5b"],
      ["v17", "Bruna, the Fading Light", "5"],
      ["v17", "Gisela, the Broken Blade", "10"],
      ["fin", "Fang, Fearless l'Cie", "381"],
      ["fin", "Fang, Fearless l'Cie", "446"],
      ["fin", "Fang, Fearless l'Cie", "526"],
      ["fin", "Fang, Fearless l'Cie", "99"],
      ["fin", "Ragnarok, Divine Deliverance", "381b"],
      ["fin", "Ragnarok, Divine Deliverance", "446b"],
      ["fin", "Ragnarok, Divine Deliverance", "526b"],
      ["fin", "Ragnarok, Divine Deliverance", "99b"],
      ["fin", "Vanille, Cheerful l'Cie", "211"],
      ["fin", "Vanille, Cheerful l'Cie", "392"],
      ["fin", "Vanille, Cheerful l'Cie", "475"],
      ["fin", "Vanille, Cheerful l'Cie", "537"],
    ])
  end

  it "rarities" do
    db.printings.map(&:rarity).to_set.should eq(
      Set["rare", "special", "common", "uncommon", "mythic", "basic"]
    )
  end

  it "&amp;" do
    index_json.should_not include("&amp;")
  end

  it "Æ" do
    bad_characters = /Æ/i
    db.printings.each do |printing|
      printing.name.should_not match(bad_characters)
      printing.text.should_not match(bad_characters)
      printing.artist.should_not match(bad_characters)
      printing.flavor.should_not match(bad_characters)
    end
  end
end
