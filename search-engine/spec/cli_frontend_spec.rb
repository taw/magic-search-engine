describe "CLI Frontend" do
  include_context "db"

  let(:cli) { $cli_frontend ||= CLIFrontend.new(db) }

  it "non_verbose" do
    assert_cli(
      search: "angel serenity",
      verbose: false,
      output: <<-EOF,
        Angel of Serenity
        EOF
      error: ""
    )
    assert_cli(
      search: "t:forest e:lea",
      verbose: false,
      output: <<-EOF,
        Bayou
        Forest
        Savannah
        Taiga
        Tropical Island
        EOF
      error: ""
    )
  end

  it "verbose_all_sets" do
    assert_cli(
      search: "is:ante t:sorcery c:b",
      verbose: true,
      output: <<-EOF,
        Contract from Below {b}
        [lea leb 2ed ced cei 3ed sum]
        Sorcery
        Remove this card from your deck before playing if you're not playing for ante.
        Discard your hand, ante the top card of your library, then draw seven cards.

        Darkpact {b}{b}{b}
        [lea leb 2ed ced cei 3ed sum]
        Sorcery
        Remove this card from your deck before playing if you're not playing for ante.
        You own target card in the ante. Exchange that card with the top card of your library.

        Demonic Attorney {1}{b}{b}
        [lea leb 2ed ced cei 3ed sum]
        Sorcery
        Remove this card from your deck before playing if you're not playing for ante.
        Each player antes the top card of their library.
        EOF
      error: ""
    )
    assert_cli(
      search: "!Jeweled Bird",
      verbose: true,
      output: <<-EOF,
        Jeweled Bird {1}
        [arn chr rin]
        Artifact
        Remove this card from your deck before playing if you're not playing for ante.
        {T}: Ante this artifact. If you do, put all other cards you own from the ante into your graveyard, then draw a card.
        EOF
      error: ""
    )
  end

  it "verbose_linebreaks" do
    assert_cli(
      search: "is:ante t:creature",
      verbose: true,
      output: <<-EOF,
        Tempest Efreet {1}{r}{r}{r}
        [leg 4ed ren]
        Creature - Efreet
        Remove this card from your deck before playing if you're not playing for ante.
        {T}, Sacrifice this creature: Target opponent may pay 10 life. If that player doesn't, they reveal a card at random from their hand. Exchange ownership of the revealed card and Tempest Efreet. Put the revealed card into your hand and Tempest Efreet from anywhere into that player's graveyard. This change in ownership is permanent.
        3/3

        Timmerian Fiends {1}{b}{b}
        [hml]
        Creature - Horror
        Remove this card from your deck before playing if you're not playing for ante.
        {B}{B}{B}, Sacrifice this creature: The owner of target artifact may ante the top card of their library. If that player doesn't, exchange ownership of that artifact and Timmerian Fiends. Put the artifact card into your graveyard and Timmerian Fiends from anywhere into that player's graveyard. This change in ownership is permanent.
        1/1
        EOF
      error: ""
    )
  end

  it "verbose color indicator (gone now)" do
    assert_cli(
      search: "mana=4 c:u c:w",
      verbose: true,
      output: <<-EOF,
        Transguild Courier {4}
        [dis dmc]
        Artifact Creature - Golem
        Transguild Courier is all colors.
        3/3
        EOF
      error: ""
    )
  end

  it "verbose color indicator" do
    assert_cli(
      search: "!Gobland",
      verbose: true,
      output: <<-EOF,
        Gobland
        [mb2]
        Land Creature - Mountain Goblin
        (Color indicator: Gobland is red)
        (Gobland isn't a spell, it's affected by summoning sickness, and it has "{T}: Add {R}.")
        Gobland can't block.
        2/1
        EOF
      error: ""
    )
  end

  it "verbose reminder text" do
    assert_cli(
      search: "!Bayou",
      verbose: true,
      output: <<-EOF,
        Bayou
        [lea leb 2ed ced cei 3ed sum me3 me4 prm vma olgc olgc 30a 30a]
        Land - Swamp Forest
        ({T}: Add {B} or {G}.)
        EOF
      error: ""
    )
  end

  it "verbose_some_sets" do
    assert_cli(
      search: "a:poole !crusade",
      verbose: true,
      output: <<-EOF,
        Crusade {w}{w}
        [+lea +leb +2ed +ced +cei +3ed +sum +4ed -5ed -6ed +psus +me1 -ddf +prm]
        Enchantment
        White creatures get +1/+1.
        EOF
      error: ""
    )
  end

  it "error_reporting" do
    assert_cli(
      search: "timerian",
      verbose: false,
      output: <<-EOF,
        Timmerian Fiends
        EOF
      error: <<-EOF
        Trying spelling "timmerian" in addition to "timerian"
        EOF
    )
    assert_cli(
      search: %[time:"Battle for Homelands" is:ante],
      verbose: false,
      output: <<-EOF,
        Amulet of Quoz
        Bronze Tablet
        Contract from Below
        Darkpact
        Demonic Attorney
        Jeweled Bird
        Rebirth
        Tempest Efreet
        Timmerian Fiends
        EOF
      error: <<-EOF
        Doesn't look like correct date, ignored: "battle for homelands"
        EOF
    )
  end

  # view:checklist prints one tab separated "SET<TAB>number<TAB>name" line per printing.
  # Heredocs would turn the tabs into something unreadable, so build the expected output by hand.
  def checklist(*lines)
    lines.map{|line| "#{line}\n"}.join
  end

  it "checklist view" do
    assert_cli(
      search: "view:checklist e:ust Ineffable Blessing",
      verbose: false,
      output: checklist(
        "UST\t113a\tIneffable Blessing (a)",
        "UST\t113b\tIneffable Blessing (b)",
        "UST\t113c\tIneffable Blessing (c)",
        "UST\t113d\tIneffable Blessing (d)",
        "UST\t113e\tIneffable Blessing (e)",
        "UST\t113f\tIneffable Blessing (f)",
      ),
      error: ""
    )
  end

  it "checklist view lists every printing, with set codes upcased" do
    assert_cli(
      search: "view:checklist !Contract from Below",
      verbose: false,
      output: checklist(
        "SUM\t97\tContract from Below",
        "3ED\t97\tContract from Below",
        "2ED\t97\tContract from Below",
        "LEB\t97\tContract from Below",
        "LEA\t96\tContract from Below",
        "CED\t97\tContract from Below",
        "CEI\t97\tContract from Below",
      ),
      error: ""
    )
  end

  it "checklist view with no results" do
    assert_cli(
      search: "view:checklist e:lea t:legendary",
      verbose: false,
      output: "",
      error: ""
    )
  end

  it "display: is an alias for view:" do
    assert_cli(
      search: "display:checklist e:ust cn:113a",
      verbose: false,
      output: checklist("UST\t113a\tIneffable Blessing (a)"),
      error: ""
    )
  end

  it "verbose takes precedence over checklist view" do
    assert_cli(
      search: "view:checklist jeweled bird",
      verbose: true,
      output: <<-EOF,
        Jeweled Bird {1}
        [arn chr rin]
        Artifact
        Remove this card from your deck before playing if you're not playing for ante.
        {T}: Ante this artifact. If you do, put all other cards you own from the ante into your graveyard, then draw a card.
        EOF
      error: ""
    )
  end

  # The interface could be extended to support things like:
  # * syntax error reporting
  # * spelling suggestions


  def assert_cli(**args)
    expected_output = strip_indent(args[:output])
    expected_error  = strip_indent(args[:error])
    out, err = capture_io{ cli.call(args[:verbose], args[:search]) }
    err.should eq(expected_error)
    out.should eq(expected_output)
  end

  def strip_indent(str)
    str.gsub(/^ {8}/, "")
  end

  def capture_io
    orig_stdout, orig_stderr         = $stdout, $stderr
    captured_stdout, captured_stderr = StringIO.new, StringIO.new
    $stdout, $stderr                 = captured_stdout, captured_stderr
    yield
    [captured_stdout.string, captured_stderr.string]
   ensure
    $stdout, $stderr = orig_stdout, orig_stderr
  end
end
