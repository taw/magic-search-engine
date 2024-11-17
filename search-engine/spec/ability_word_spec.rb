describe "Ability Word Regexp" do
  include_context "db"

  it "ability words and similar" do
    # 207.2c
    # An ability word appears in italics at the beginning of some abilities. Ability words are similar to keywords in that they tie together cards that have similar functionality, but they have no special rules meaning and no individual entries in the Comprehensive Rules. The ability words are battalion, bloodrush, channel, chroma, cohort, constellation, converge, council’s dilemma, delirium, domain, eminence, enrage, fateful hour, ferocious, formidable, grandeur, hellbent, heroic, imprint, inspired, join forces, kinship, landfall, lieutenant, metalcraft, morbid, parley, radiance, raid, rally, revolt, spell mastery, strive, sweep, tempting offer, threshold, and will of the council."

    # If this list ever changes, this test should fail

    other_phrases = [
      "An opponent chooses one",
      "Boast",
      "Choose a scheme and set it into motion",
      "Choose one at random", # playtest cards
      "Choose one or both",
      "Choose one or more",
      "Choose one",
      "Choose two",
      "Companion",
      "DCI ruling",
      "Escape",
      "Family gathering",
      "Forecast",
      "I",
      "II",
      "III",
      "IV",
      # "V", # somehow skipped?
      "VI",
      "Prize",
      "Ransom", # playtest cards
      "Solved",
      "Target opponent chooses one",
      "To solve",
      "Visit",
    ]

    card_texts = db.cards.values.map(&:text)
    dash_prefixes = card_texts.map{|t| t.scan(/^([a-zA-Z' ]+) —/)}.flatten.uniq.sort
    ability_words = card_texts.map{|t| t.scan(Card::ABILITY_WORD_RX)}.flatten.uniq.sort
    (ability_words - dash_prefixes).should eq([])
    (dash_prefixes - ability_words).should match_array(other_phrases)
    ability_words.should match_array(Card::ABILITY_WORD_LIST)
  end
end
