# m/n/o are variables for distinct colors, h is a variable for a hybrid symbol

describe "mana variables" do
  include_context "db"

  it "single variable" do
    assert_search_equal "b:ravnica guildmage mana=hh", "b:ravnica guildmage c:m cmc=2"
    assert_search_equal "e:rtr mana=h", "e:rtr c:m cmc=1"
    assert_search_results "mana>mmmmm",
      "B.F.M. (Big Furry Monster)",
      "B.F.M. (Big Furry Monster, Right Side)",
      "Doomsday Excruciator",
      "Khalni Hydra",
      "Primalcrux"
  end

  it "multiple variables" do
    assert_count_cards "e:ktk (charm OR ascendancy) mana=mno", 10
    assert_count_cards "e:ktk mana=mno", 15
    assert_search_results "mana=mmnnnoo",
      "Brilliant Ultimatum",
      "Clarion Ultimatum",
      "Cruel Ultimatum",
      "Eerie Ultimatum",
      "Emergent Ultimatum",
      "Genesis Ultimatum",
      "Inspired Ultimatum",
      "Ruinous Ultimatum",
      "Titanic Ultimatum",
      "Violent Ultimatum"
    assert_search_results "mana=wwmmmnn",
      "Brilliant Ultimatum",
      "Eerie Ultimatum",
      "Inspired Ultimatum",
      "Titanic Ultimatum"
  end

  it "variables are interchangeable" do
    assert_search_equal "mana=mmnnnoo", "mana=nnooomm"
    assert_search_equal "mana>nnnnn", "mana>ooooo"
    assert_search_equal "mana=mno", "mana={m}{n}{o}"
    assert_search_equal "mana=mmn", "mana=mnn"
    assert_search_equal "mana=mmn", "mana>=mnn mana <=mmn"
  end

  it "hybrid variable" do
    assert_count_cards "mana>=mh game:paper", 36
    assert_search_results "mana=mh game:paper",
      "Bant Sureblade",
      "Crystallization",
      "Esper Stormblade",
      "Grixis Grimblade",
      "Jund Hackblade",
      "Kaust, Eyes of the Glade",
      "Naya Hushblade",
      "Sangrite Backlash",
      "Thopter Foundry",
      "Trace of Abundance"
    assert_search_equal "mana=mh", "mana={m}{h}"
  end

  it "variables expand to every color" do
    assert_search_equal "mana={w}{m}", "mana={w}{u} OR mana={w}{b} OR mana={w}{r} OR mana={w}{g}"
    assert_search_equal "mana={m}{h}", "mana={w}{h} OR mana={u}{h} OR mana={b}{h} OR mana={r}{h} OR mana={g}{h}"
    # Only {w}{u/b} of these exists, no cards have hybrid and nonhybrid of same color in mana cost yet
    assert_search_equal "mana={m}{w/b}", "mana={w}{w/b} OR mana={u}{w/b} OR mana={b}{w/b} OR mana={r}{w/b} OR mana={g}{w/b}"
  end
end

# Resolving variables against every printing is expensive and pointless, as the
# answer only depends on the mana cost and there are ~870 of those in the whole
# index, so ConditionMana memoizes by cost.
describe "ConditionMana caching" do
  include_context "db"

  let(:printings) { db.printings }

  def uncached(op, mana)
    cond = ConditionMana.new(op, mana)
    printings.select{|card| cond.send(:match_mana?, card.mana_hash) }
  end

  def cached(op, mana)
    cond = ConditionMana.new(op, mana)
    printings.select{|card| cond.match?(card) }
  end

  # A mana query answers "no" for most of the index, so caching that has to
  # work as well as caching "yes" - `@cache[cost] ||= ...` would recompute
  # every miss and quietly give back all of the cost with none of the benefit
  # `@cache[cost] ||= ...` would answer correctly and cache nothing useful: a
  # mana query says "no" for most of the index, and every one of those misses
  # would be recomputed on the next printing with the same cost
  it "computes each distinct mana cost once, negative answers included" do
    cond = ConditionMana.new("=", "hh")
    calls = 0
    cond.define_singleton_method(:match_mana?) do |card_mana|
      calls += 1
      super(card_mana)
    end
    printings.each{|card| cond.match?(card) }
    calls.should eq(printings.map(&:mana_cost).uniq.size)
    cond.instance_variable_get(:@cache).values.count(false).should be > 0
  end

  it "gives the same results as recomputing per printing" do
    mismatched = []
    %w[= != > >= < <=].each do |op|
      ["", "2g", "m", "mm", "hh", "mno", "{2/w}{2/w}", "wubrg"].each do |mana|
        mismatched << "mana#{op}#{mana}" unless cached(op, mana) == uncached(op, mana)
      end
    end
    mismatched.should eq([])
  end

  # ConditionAnd .uniqs subconditions by #hash, so cache contents must stay out
  # of equality or a condition would stop matching itself once it has run
  it "stays equal to an identical condition after running" do
    used = ConditionMana.new(">", "mm")
    fresh = ConditionMana.new(">", "mm")
    printings.each{|card| used.match?(card) }
    used.should eq(fresh)
    used.hash.should eq(fresh.hash)
    [used, fresh].uniq.size.should eq(1)
    used.should_not eq(ConditionMana.new(">", "gg"))
  end
end
