describe "CLI Frontend" do
  let(:cli) { $cli_frontend ||= CLIFrontend.new }

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
      search: "t:forest",
      verbose: false,
      output: <<-EOF,
        Bayou
        Breeding Pool
        Canopy Vista
        Cinder Glade
        Dryad Arbor
        Forest
        Murmuring Bosk
        Overgrown Tomb
        Sapseep Forest
        Savannah
        Scattered Groves
        Sheltered Thicket
        Snow-Covered Forest
        Stomping Ground
        Taiga
        Temple Garden
        Tropical Island
        EOF
      error: ""
    )
  end

  it "verbose_all_sets" do
    assert_cli(
      search: "jace beleren",
      verbose: true,
      output: <<-EOF,
        Jace Beleren {1}{u}{u}
        [lw jvc mbp m10 m11 ddajvc]
        Legendary Planeswalker - Jace
        [+2]: Each player draws a card.
        [-1]: Target player draws a card.
        [-10]: Target player puts the top twenty cards of their library into their graveyard.
        Loyalty: 3
        EOF
      error: ""
    )
    assert_cli(
      search: "siege rhino",
      verbose: true,
      output: <<-EOF,
        Siege Rhino {1}{w}{b}{g}
        [ptc ktk cp3]
        Creature - Rhino
        Trample
        When Siege Rhino enters the battlefield, each opponent loses 3 life and you gain 3 life.
        4/5
        EOF
      error: ""
    )
  end

  it "verbose_linebreaks" do
    assert_cli(
      search: "mana=4gg t:dragon",
      verbose: true,
      output: <<-EOF,
        Canopy Dragon {4}{g}{g}
        [mr]
        Creature - Dragon
        Trample
        {1}{G}: Canopy Dragon gains flying and loses trample until end of turn.
        4/4

        Destructor Dragon {4}{g}{g}
        [frf]
        Creature - Dragon
        Flying
        When Destructor Dragon dies, destroy target noncreature permanent.
        4/4
        EOF
      error: ""
    )
  end

  it "verbose color indicator" do
    assert_cli(
      search: "mana=4 c:u c:w",
      verbose: true,
      output: <<-EOF,
        Transguild Courier {4}
        [di]
        Artifact Creature - Golem
        (Color indicator: Transguild Courier is all colors)
        3/3
        EOF
      error: ""
    )
  end

  it "verbose reminder text" do
    assert_cli(
      search: "steam vents",
      verbose: true,
      output: <<-EOF,
        Steam Vents
        [gp rtr exp]
        Land - Island Mountain
        ({T}: Add {U} or {R}.)
        As Steam Vents enters the battlefield, you may pay 2 life. If you don't, Steam Vents enters the battlefield tapped.
        EOF
      error: ""
    )
  end

  it "verbose_some_sets" do
    assert_cli(
      search: "bloodbraid elf a:steve",
      verbose: true,
      output: <<-EOF,
        Bloodbraid Elf {2}{r}{g}
        [-arb +fnmp +pc2 -ema -c16 +pca]
        Creature - Elf Berserker
        Haste
        Cascade
        3/2
        EOF
      error: ""
    )
  end

  it "error_reporting" do
    assert_cli(
      search: "kolagan",
      verbose: false,
      output: <<-EOF,
        Dragonlord Kolaghan
        Kolaghan Aspirant
        Kolaghan Forerunners
        Kolaghan Monument
        Kolaghan Skirmisher
        Kolaghan Stormsinger
        Kolaghan's Command
        Kolaghan, the Storm's Fury
        EOF
      error: <<-EOF
        Trying spelling "kolaghan" in addition to "kolagan"
        EOF
    )
    assert_cli(
      search: %Q[time:"Battle for Homelands" t:ral],
      verbose: false,
      output: <<-EOF,
        Ral Zarek
        EOF
      error: <<-EOF
        Doesn't look like correct date, ignored: "battle for homelands"
        EOF
    )
  end

  # The interface could be extended to support things like:
  # * syntax error reporting
  # * spelling suggestions

  def assert_cli(**args)
    expected_output = strip_indent(args[:output])
    expected_error  = strip_indent(args[:error])
    out, err = capture_io{ cli.run!(args[:verbose], false, args[:search]) }
    err.should eq(expected_error)
    out.should eq(expected_output)
  end

  def strip_indent(str)
    str.gsub(/^ {8}/, "")
  end

  def capture_io
    require "stringio"
    orig_stdout, orig_stderr         = $stdout, $stderr
    captured_stdout, captured_stderr = StringIO.new, StringIO.new
    $stdout, $stderr                 = captured_stdout, captured_stderr
    yield
    [captured_stdout.string, captured_stderr.string]
   ensure
    $stdout, $stderr = orig_stdout, orig_stderr
  end
end
