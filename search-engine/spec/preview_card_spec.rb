# Deck pages show one card of the deck as a big picture
describe "PhysicalCard.best_preview" do
  include_context "db", "mrd", "nph", "arn"

  def preview_name(*queries)
    cards = queries.flat_map{|query| physical_cards(query)}
    PhysicalCard.best_preview(cards).name
  end

  it "prefers the rarest, splashiest card" do
    # A mythic planeswalker beats a rare legendary artifact creature,
    # which beats a common creature, which beats a land
    preview_name("!Karn Liberated", "!Bosh, Iron Golem", "!Alpha Myr", "!Blinkmoth Well")
      .should eq "Karn Liberated"
    preview_name("!Bosh, Iron Golem", "!Alpha Myr", "!Blinkmoth Well")
      .should eq "Bosh, Iron Golem"
    preview_name("!Alpha Myr", "!Blinkmoth Well").should eq "Alpha Myr"
    preview_name("!Blinkmoth Well").should eq "Blinkmoth Well"
  end

  it "breaks ties by name, so the same deck always previews the same card" do
    # Arabian Nights has no rarer-than-uncommon anything, and no legends
    preview_name("e:arn t:instant").should eq "Army of Allah"
  end

  it "scores cards for the preview" do
    physical_card("!Karn Liberated").preview_score.should eq 10110
    physical_card("!Bosh, Iron Golem").preview_score.should eq 1011
    physical_card("!Alpha Myr").preview_score.should eq 1
    physical_card("!Blinkmoth Well").preview_score.should eq 0
  end

  it "has nothing to preview for an empty deck" do
    PhysicalCard.best_preview([]).should eq nil
  end
end
