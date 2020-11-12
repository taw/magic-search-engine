describe "Shandalar" do
  include_context "db"

  it "nothing outside specific sets is there" do
    assert_search_results "game:shandalar -e:lea,leb,2ed,3ed,arn,atq,leg,drk,past,phpr,pdrc"
  end

  it "most early set cards are in Shandalar" do
    assert_search_results "-game:shandalar e:lea,leb,2ed,3ed",
      "Bog Wraith",
      "Camouflage",
      "Chaos Orb",
      "False Orders",
      "Illusionary Mask",
      "Word of Command"
  end
end
