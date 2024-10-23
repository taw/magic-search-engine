describe "Planechase" do
  include_context "db", "hop", "pc2", "pca", "m13", "opca"

  it "plane" do
    assert_search_results "t:plane t:Dominaria", "Krosa", "Llanowar", "Academy at Tolaria West", "Isle of Vesuva", "Otaria", "Shiv", "Talon Gates"
    assert_search_results "t:Dominaria", "Krosa", "Llanowar", "Academy at Tolaria West", "Isle of Vesuva", "Otaria", "Shiv", "Talon Gates"
    assert_search_equal "t:plane or t:phenomenon", "layout:plane"
  end

  it "chaos symbol" do
    # A lot of cards had "Whenever you roll {CHAOS}", but it got changed do "Whenever chaos ensues" so all of this is gone
    # The only use of {CHAOS} is by Chaotic Aether which uses it in different context
    assert_search_results %[o:{CHAOS}], "Chaotic Aether"
  end

  it "phenomenon" do
    assert_search_results %[t:phenomenon o:"each player draws four cards"], "Mutual Epiphany"
  end

  it "bang search doesn't require explicit flags" do
    assert_search_results "!Talon Gates", "Talon Gates"
    assert_search_results "!Mutual Epiphany", "Mutual Epiphany"
  end

  it "plane cards included by default" do
    assert_search_results 'o:"untap all creatures you control"',
      "Llanowar"
  end

  it "phenomenon cards included by default" do
    assert_search_results %[o:"each player draws four cards"],
      "Mutual Epiphany"
  end

  # t: operator assumes there are no spaces in type names, so
  # t:"legendary goblin" works as t:legendary t:goblin
  #
  # Since it's all hacks to make this work, let's list the hacks
  #
  # 205.3b
  # Subtypes of each card type except plane are always single words and are listed after a long dash. Each word after the dash is a separate subtype; such objects may have multiple types. Subtypes of planes are also listed after a long dash, but may be multiple words; all words after the dash are, collectively, a single subtype.
  it "types with spaces in them" do
    # These are separate types
    assert_search_results %[t:"new phyrexia"], "Furnace Layer", "Norn's Dominion"
    assert_search_results %[t:"new-phyrexia"], "Furnace Layer", "Norn's Dominion"
    assert_search_results %[t:new-phyrexia], "Furnace Layer", "Norn's Dominion"
    assert_search_results %[t:new]
    assert_search_results %[t:phyrexia], "The Fourth Sphere"

    assert_search_results %[t:"serra realm"], "Sanctum of Serra"
    assert_search_results %[t:"serra-realm"], "Sanctum of Serra"
    assert_search_results %[t:serra-realm], "Sanctum of Serra"
    assert_search_results %[t:serra]
    assert_search_results %[t:realm]

    # Note that t:bolas is its own thing too, so we load M13 specifically to test this
    assert_search_results %[t:"bolas's meditation realm"], "Pools of Becoming"
    assert_search_results %[t:"bolas's-meditation-realm"], "Pools of Becoming"
    assert_search_results %[t:"bolas meditation realm"], "Pools of Becoming"
    assert_search_results %[t:"bolas-meditation-realm"], "Pools of Becoming"
    assert_search_results %[t:bolas's-meditation-realm], "Pools of Becoming"
    assert_search_results %[t:bolas-meditation-realm], "Pools of Becoming"
    assert_search_results %[t:bolas's], "Nicol Bolas, Planeswalker"
    assert_search_results %[t:bolas], "Nicol Bolas, Planeswalker"
    assert_search_results %[t:meditation]
    assert_search_results %[t:realm]
  end
end
