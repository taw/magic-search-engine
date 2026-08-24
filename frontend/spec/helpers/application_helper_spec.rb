require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  def printing(set_code, number)
    $CardDatabase.sets[set_code].printings.find{|cp| cp.number == number} or
      raise "No card #{set_code}:#{number}"
  end

  let(:karn) { printing("nph", "1") }
  let(:bolt) { printing("lea", "161") }

  # We build these by hand instead of calling url_for, so they need checking
  describe "urls" do
    it "card" do
      expect(helper.card_url(karn)).to eq "/card/nph/1/Karn-Liberated"
      expect(helper.url_for_card(karn)).to eq "/card/nph/1/Karn-Liberated"
      expect(helper.card_gallery_url(karn)).to eq "/card/gallery/nph/1"
    end

    # ★ in collector numbers, and anything else url_for would have escaped
    it "card with a collector number needing escaping" do
      display = printing("oarc", "8★")
      expect(helper.card_url(display)).to eq "/card/oarc/8%E2%98%85/A-Display-of-My-Dark-Power"
      expect(helper.card_gallery_url(display)).to eq "/card/gallery/oarc/8%E2%98%85"
    end

    it "search" do
      expect(helper.search_url("t:goblin r:rare")).to eq "/card?q=t%3Agoblin+r%3Arare"
      expect(helper.card_name_url("Ancestral Recall")).to eq "/card?q=%21Ancestral+Recall"
      expect(helper.subset_url("who", "Doctor Who")).to eq %[/card?q=e%3Awho+subset%3A%22Doctor+Who%22]
    end

    it "set, pack, artist" do
      expect(helper.set_url($CardDatabase.sets["nph"])).to eq "/set/nph"
      expect(helper.pack_url($CardDatabase.supported_booster_types["nph-draft"])).to eq "/pack/nph-draft"
      expect(helper.artist_url($CardDatabase.artists["steve_ellis"])).to eq "/artist/steve_ellis"
    end

    it "format" do
      expect(helper.format_url("Shards of Alara Block")).to eq "/format/shards-of-alara-block"
    end

    it "deck" do
      deck = $CardDatabase.sets["jou"].decks.find{|d| d.slug == "fates-foreseen"}
      expect(helper.deck_url(deck)).to eq "/deck/jou/fates-foreseen"
      expect(helper.deck_download_url(deck)).to eq "/deck/jou/fates-foreseen/download"
      expect(helper.deck_download_with_printings_url(deck)).to eq "/deck/jou/fates-foreseen/download_with_printings"
    end

    it "product" do
      product = $CardDatabase.sets["nph"].products.find{|p| p.slug == "new_phyrexia_booster_box"}
      expect(helper.product_url(product)).to eq "/product/nph/new_phyrexia_booster_box"
    end

    it "limited format" do
      limited_format = $CardDatabase.sets["dgm"].limited_formats.find{|f| f.slug == "prerelease-sealed"}
      expect(helper.limited_format_url(limited_format)).to eq "/limited_format/dgm/prerelease-sealed"
    end

    # url_for drops nil params, Hash#to_query would render them as "key="
    it "drops empty params" do
      expect(helper.url_query(a: "1", b: nil, c: "3")).to eq "a=1&c=3"
    end
  end

  describe "#format_oracle_text" do
    it "renders mana symbols" do
      expect(helper.format_oracle_text(karn.display_mana_cost)).to eq(
        %[<span class="manacost">] +
        %[<span class="mana mana-cost mana-7"><span class="sr-only">{7}</span></span>] +
        %[</span>]
      )
    end

    it "renders loyalty abilities" do
      expect(helper.format_oracle_text("[+4]: Draw a card.")).to eq(
        %[<i class="mana mana-loyalty mana-loyalty-up mana-loyalty-4"></i>] +
        %[<span class="sr-only">[+4]</span>: Draw a card.]
      )
    end

    it "renders reminder text in italics, nested parentheses and all" do
      expect(helper.format_oracle_text("Flying (It can't be blocked.)")).to eq(
        %[Flying <i class="reminder-text">(It can't be blocked.)</i>]
      )
      expect(helper.format_oracle_text("Urza (a (nested) thing) end")).to eq(
        %[Urza <i class="reminder-text">(a (nested) thing)</i> end]
      )
    end

    it "renders ability words in italics" do
      punch = printing("ktk", "147")
      expect(helper.format_oracle_text(punch.text)).to include(
        %[<i class='ability_word'>Ferocious</i> —]
      )
    end

    it "renders newlines as line breaks" do
      expect(helper.format_oracle_text("First\nSecond")).to eq "First<br/>Second"
    end

    it "escapes html, but leaves apostrophes alone" do
      expect(helper.format_oracle_text(%[<b>x</b> & "y" 'z'])).to eq(
        %[&lt;b&gt;x&lt;/b&gt; &amp; &quot;y&quot; 'z']
      )
    end

    it "has nothing to render for a card without text" do
      expect(helper.format_oracle_text(nil)).to eq ""
    end

    it "leaves leading newlines out" do
      expect(helper.format_oracle_text("\n\nFlying")).to eq "Flying"
    end
  end

  describe "#format_mana_symbols_in_text" do
    it "renders every symbol we have an icon for" do
      expect(helper.format_mana_symbols_in_text("{2/W}{W/U}{G/P}{X}{S}{T}{Q}{C}")).to eq(
        %[<span class="manacost">] +
        %[<span class="mana mana-cost mana-2w"><span class="sr-only">{2/W}</span></span>] +
        %[<span class="mana mana-cost mana-wu"><span class="sr-only">{W/U}</span></span>] +
        %[<span class="mana mana-cost mana-gp"><span class="sr-only">{G/P}</span></span>] +
        %[<span class="mana mana-cost mana-x"><span class="sr-only">{X}</span></span>] +
        %[<span class="mana mana-cost mana-s"><span class="sr-only">{S}</span></span>] +
        %[<span class="mana mana-cost mana-t"><span class="sr-only">{T}</span></span>] +
        %[<span class="mana mana-cost mana-q"><span class="sr-only">{Q}</span></span>] +
        %[<span class="mana mana-cost mana-c"><span class="sr-only">{C}</span></span>] +
        %[</span>]
      )
    end

    it "renders symbols which get no circle around them" do
      expect(helper.format_mana_symbols_in_text("{E}{CHAOS}{PW}")).to eq(
        %[<span class="manacost">] +
        %[<span class="mana mana-e"><span class="sr-only">{E}</span></span>] +
        %[<span class="mana mana-chaos"><span class="sr-only">{CHAOS}</span></span>] +
        %[<span class="mana mana-pw"><span class="sr-only">{PW}</span></span>] +
        %[</span>]
      )
    end

    it "renders half mana symbols" do
      expect(helper.format_mana_symbols_in_text("{HW}")).to eq(
        %[<span class="manacost">] +
        %[<span class="mana mana-half"><span class="mana mana-cost mana-w"><span class="sr-only">{HW}</span></span></span>] +
        %[</span>]
      )
    end

    it "leaves symbols we have no icon for as they are" do
      expect(helper.format_mana_symbols_in_text("{FOO}")).to eq %[<span class="manacost">{FOO}</span>]
    end

    it "renders loyalty symbols of every direction" do
      expect(helper.format_mana_symbols_in_text("[+4] [-3] [0] [-X]")).to eq(
        %[<i class="mana mana-loyalty mana-loyalty-up mana-loyalty-4"></i><span class="sr-only">[+4]</span> ] +
        %[<i class="mana mana-loyalty mana-loyalty-down mana-loyalty-3"></i><span class="sr-only">[–3]</span> ] +
        %[<i class="mana mana-loyalty mana-loyalty-zero mana-loyalty-0"></i><span class="sr-only">[0]</span> ] +
        %[<i class="mana mana-loyalty mana-loyalty-down mana-loyalty-x"></i><span class="sr-only">[–X]</span>]
      )
    end

    # Pick Your Poison (CMB1) literally has "[1]" and "[2]" on the paper card
    it "leaves plain bracketed numbers alone" do
      expect(helper.format_mana_symbols_in_text("Choose [1] or [2].")).to eq "Choose [1] or [2]."
    end
  end

  describe "#printings_view" do
    let(:view) { helper.printings_view(karn, [karn, printing("uma", "5")]) }
    let(:flagged) { view.flat_map{|set_name, printings| printings} }

    it "flags the selected printing, the matching ones, and the rest" do
      expect(flagged.select{|type, cp| type == :selected}.map(&:last)).to eq [karn]
      expect(flagged.select{|type, cp| type == :matching}.map(&:last)).to eq [printing("uma", "5")]
      expect(flagged.map(&:last)).to match_array karn.printings
    end

    it "groups by set, newest set first" do
      expect(view.map(&:first)).to eq view.map(&:first).uniq
      view.map{|set_name, printings| printings[0].last.release_date}.each_cons(2) do |newer, older|
        expect(newer).to be >= older
      end
    end
  end

  describe "#printings_view_full" do
    let(:view) { helper.printings_view_full(karn, [karn]) }

    # Double Masters printed Karn at the same rarity twice, so it's one group,
    # while a set printing a card at two rarities gets one group per rarity
    it "groups by set and rarity" do
      expect(view.map(&:first)).to eq view.map(&:first).uniq
      view.map(&:first).each do |set_name, rarity|
        expect(rarity).to eq "mythic"
      end
      expect(view.flat_map(&:last).map(&:last)).to match_array karn.printings
    end
  end

  describe "#pack_alternatives" do
    let(:packs) do
      %W[gtc-prerelease-orzhov gtc-prerelease-dimir].map{|code| $CardDatabase.supported_booster_types[code]}
    end

    it "reads as English" do
      expect(helper.pack_alternatives(packs)).to eq(
        %[<a href="/pack/gtc-prerelease-orzhov">Gatecrash Prerelease Pack Orzhov</a> (GTC-PRERELEASE-ORZHOV)] +
        %[ or ] +
        %[<a href="/pack/gtc-prerelease-dimir">Gatecrash Prerelease Pack Dimir</a> (GTC-PRERELEASE-DIMIR)]
      )
    end

    it "uses an Oxford comma for three or more" do
      boros = $CardDatabase.supported_booster_types["gtc-prerelease-boros"]
      expect(helper.pack_alternatives(packs + [boros])).to include ", or "
    end
  end

  describe "#sealed_simulator_url" do
    let(:pool) do
      $CardDatabase.sets["dgm"]
        .limited_formats.find{|f| f.slug == "prerelease-sealed"}
        .pools.find{|p| p.slug == "azorius"}
    end

    it "asks the simulator for the packs and the promos of the pool" do
      expect(helper.sealed_simulator_url(pool)).to eq(
        "/sealed?" +
        "count%5B%5D=4&count%5B%5D=1&count%5B%5D=1&" +
        "fixed=1x+pdgm%3A152%E2%98%85%3Afoil%0A1x+pdgm%3A157%E2%98%85%3Afoil&" +
        "set%5B%5D=dgm-draft&set%5B%5D=rtr-prerelease-azorius&" +
        "set%5B%5D=gtc-prerelease-orzhov%7Cgtc-prerelease-dimir%7Cgtc-prerelease-boros%7Cgtc-prerelease-simic"
      )
    end

    # The link writes the promos out, the simulator reads them back in
    it "writes promos in the format the simulator parses" do
      fixed = Rack::Utils.parse_nested_query(helper.sealed_simulator_url(pool).split("?", 2).last)["fixed"]
      expect(FixedCardList.new($CardDatabase, fixed).cards).to eq pool.promo_cards
    end

    it "has no fixed cards for a pool without promos" do
      pool = $CardDatabase.sets["dgm"].limited_formats.find{|f| f.slug == "sealed"}.pools.first
      expect(pool.promo_cards).to eq []
      expect(helper.sealed_simulator_url(pool)).to_not include "fixed"
    end
  end

  describe "#limited_format_page?" do
    it "is true for formats we have a page for" do
      formats = $CardDatabase.sets["dgm"].limited_formats
      expect(helper.limited_format_page?(formats.find{|f| f.type == "draft"})).to eq true
      expect(helper.limited_format_page?(formats.find{|f| f.type == "prerelease-sealed"})).to eq true
    end

    # Every format we have data for is supported right now, so this needs a
    # made-up one - the page still has to cope with formats added later
    it "is false for formats we don't" do
      expect(helper.limited_format_page?(Struct.new(:type).new("chaos-draft"))).to eq false
    end

    it "supports Arena drafts however they are numbered" do
      expect(LimitedFormatController.supported_type?("arena-draft")).to eq true
      expect(LimitedFormatController.supported_type?("arena-draft-2")).to eq true
      expect(LimitedFormatController.supported_type?("arena-draft-x")).to eq false
    end
  end

  describe "pictures" do
    # verify_scans looks for the files directly, the database looked for the
    # same two files at boot, and they must agree
    it "finds the same picture the database did" do
      $CardDatabase.sets["arn"].printings.first(20).each do |card|
        expect((helper.card_picture_path_hq(card) || helper.card_picture_path_lq(card))).to eq card.image_path
      end
    end

    it "has no picture for a card that isn't there" do
      missing = Struct.new(:set_code, :number).new("nph", "no-such-number")
      expect(helper.card_picture_path_hq(missing)).to eq nil
      expect(helper.card_picture_path_lq(missing)).to eq nil
    end

    it "links the per-card pages to the card's default printing" do
      expect(helper.card_gallery_path(printing("uma", "5"))).to eq "/card/gallery/nph/1"
      expect(helper.card_availability_path(printing("uma", "5"))).to eq "/card/availability/nph/1"
    end
  end

  describe "languages" do
    it "names languages" do
      expect(helper.language_name(:cs)).to eq "Simplified Chinese"
      expect(helper.language_name(:pt)).to eq "Brazilian Portuguese"
    end

    it "maps our language codes to the official ones" do
      expect(helper.official_language_code(:cs)).to eq "zh-CN"
      expect(helper.official_language_code(:jp)).to eq "ja"
      expect(helper.official_language_code(:fr)).to eq "fr"
    end

    it "maps languages to flags" do
      expect(helper.language_flag(:cs)).to eq "cn"
      expect(helper.language_flag(:pt)).to eq "br"
      expect(helper.language_flag(:sp)).to eq "es"
    end
  end

  describe "#preview_id" do
    it "tells foil and nonfoil copies of a card apart" do
      expect(helper.preview_id(PhysicalCard.for(karn))).to eq "nph-1"
      expect(helper.preview_id(PhysicalCard.for(karn, finish: :foil))).to eq "nph-1-foil"
    end
  end

  describe "#format_display" do
    it "links the cards a precon deck's blurb mentions" do
      expect(helper.format_display("Built around [nph:1].\nGood luck.")).to eq(
        %[Built around <a href="/card?q=e%3Anph+number%3A1+%2B%2B">[nph:1]</a>.<br/>Good luck.]
      )
    end
  end
end
