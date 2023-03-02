describe "Set types" do
  include_context "db"

  it "basic types" do
    assert_search_results "angel of wrath st:ftv", "Akroma, Angel of Wrath"
    assert_search_results "angel of wrath st:dd", "Akroma, Angel of Wrath"
    assert_search_results "angel of wrath st:expansion", "Akroma, Angel of Wrath", "Archangel of Wrath"
    assert_search_results "armageddon st:masters", "Armageddon", "Armageddon Clock"
    assert_search_results "armageddon st:core", "Armageddon", "Armageddon Clock"
    assert_search_results "armageddon st:starter", "Armageddon"
  end

  it "abbreviations" do
    assert_search_equal "st:2hg", 'st:"two-headed giant"'
    assert_search_equal "st:arc", "st:archenemy"
    assert_search_equal "st:cmd", "st:commander"
    assert_search_equal "st:cns", "st:conspiracy"
    assert_search_equal "st:dd", 'st:"duel deck"'
    assert_search_equal "st:ex", "st:expansion"
    assert_search_equal "st:ftv", 'st:"from the vault"'
    assert_search_equal "st:me", "st:masters"
    assert_search_equal "st:pc", "st:planechase"
    assert_search_equal "st:pds", 'st:"premium deck"'
    assert_search_equal "st:st", "st:starter"
    assert_search_equal "st:std", "st:standard"
  end

  it "underscores and capitalization" do
    assert_search_equal "st:duel_deck", 'st:"duel deck"'
    assert_search_equal "st:duel_deck", 'st:"DUEL DECK"'
    assert_search_equal "st:dd", 'st:DD'
  end

  it "composite types" do
    assert_search_equal "st:standard", "(st:core or st:expansion or e:w16,w17,g18)"
  end

  it "cm1 exception" do
    "desertion st:fixed".should return_cards "Desertion"
    "desertion st:cmd"  .should return_cards "Desertion"
    "desertion st:deck" .should return_no_cards
  end

  it "starter sets" do
    assert_search_results "alert shu st:booster", "Alert Shu Infantry"
    assert_search_results "knight errant st:fixed", "Knight Errant"
  end

  # mtgjson follows some but not all of them
  it "scryfall types" do
    "st:arena_league".should include_search "e:pal00,pal01,pal02,pal03,pal04,pal05,pal06,pal99,parl"
    "st:commander".should include_search "e:cmd,c13,c14,c15,c16,c17,c18,oc13,oc14,oc15,oc16,oc17,oc18,cma,cm2,cmr"
    "st:core".should include_search "e:lea,leb,2ed,3ed,4ed,5ed,6ed,7ed,8ed,9ed,10e,m10,m11,m12,m13,m14,m15,m19,m20"
    "st:duel_deck".should include_search "e:dd1,dd2,ddc,ddd,dde,ddf,ddg,ddh,ddi,ddj,ddk,ddl,ddm,ddn,ddo,ddp,ddq,ddr,dds,ddt,ddu,dvd,evg,gvl,jvc,td2"
    "st:duels".should include_search "e:pdp10,pdp11,pdp12,pdp13,pdp14,pdtp"
    "st:expansion".should include_search "e:arn,atq,leg,drk,fem,ice,hml,all,mir,vis,wth,tmp,sth,exo,usg,ulg,uds,mmq,nem,pcy,inv,pls,apc,ody,tor,jud,ons,lgn,scg,mrd,dst,5dn,chk,bok,sok,rav,gpt,dis,csp,tsp,tsb,plc,fut,lrw,mor,shm,eve,ala,con,arb,zen,wwk,roe,som,mbs,nph,isd,dka,avr,rtr,gtc,dgm,ths,bng,jou,ktk,frf,dtk,bfz,ogw,soi,emn,kld,aer,akh,hou,xln,rix,dom,grn,rna,war"
    "st:fnm".should include_search "e:f01,f02,f03,f04,f05,f06,f07,f08,f09,f10,f11,f12,f13,f14,f15,f16,f17,fnm,pdom,pgrn,pm19,prna,pwar"
    "st:from_the_vault".should include_search "e:drb,v09,v10,v11,v12,v13,v14,v15,v16,v17"
    "st:judge_gift".should include_search "e:g00,g01,g02,g03,g04,g05,g06,g07,g08,g09,g10,g11,g17,g18,g99,j12,j13,j14,j15,j16,j17,j18,j19,jgp"
    "st:masterpiece".should include_search "e:exp,mps,mp2,med,puma"
    "st:masters".should include_search "e:chr,me1,me2,me3,me4,mma,vma,tpr,mm2,ema,mm3,ima,a25,uma"
    "st:multiplayer".should include_search "st:cmd or e:bbd,cns,cn2"
    "st:player_rewards".should include_search "e:mpr,p03,p04,p05,p06,p07,p08,p09,p10,p11"
    "st:portal".should include_search "e:por,p02,ptk"
    "st:premiere_shop".should include_search "e:pmps06,pmps07,pmps08,pmps09,pmps10,pmps11"
    "st:premium_deck".should include_search "e:h09,pd2,pd3"
    "st:unset".should include_search "e:ugl,unh,ust"
  end
end
