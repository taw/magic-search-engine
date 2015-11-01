require_relative "test_helper"

class TestCLIFrontend < Minitest::Test
  def setup
    @cli = load_cli
  end

  def test_non_verbose
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
        Snow-Covered Forest
        Stomping Ground
        Taiga
        Temple Garden
        Tropical Island
        EOF
      error: ""
    )
  end

  def test_verbose_all_sets
    assert_cli(
      search: "jace beleren",
      verbose: true,
      output: <<-EOF,
        Jace Beleren {1}{u}{u}
        [lw jvc mbp m10 m11 ddajvc]
        Planeswalker - Jace
        +2: Each player draws a card.
        -1: Target player draws a card.
        -10: Target player puts the top twenty cards of his or her library into his or her graveyard.
        Loyalty: 3
        EOF
      error: ""
    )
    assert_cli(
      search: "siege rhino",
      verbose: true,
      output: <<-EOF,
        Siege Rhino {1}{w}{b}{g}
        [ptc ktk]
        Creature - Rhino
        Trample
        When Siege Rhino enters the battlefield, each opponent loses 3 life and you gain 3 life.
        4/5
        EOF
      error: ""
    )
  end

  def test_verbose_linebreaks
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

  def test_verbose_some_sets
    assert_cli(
      search: "bloodbraid elf a:steve",
      verbose: true,
      output: <<-EOF,
        Bloodbraid Elf {2}{r}{g}
        [-arb +fnmp +pc2]
        Creature - Elf Berserker
        Haste
        Cascade
        3/2
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
    out, err = capture_io{ @cli.run!(args[:verbose], args[:search]) }
    assert_equal expected_error, err
    assert_equal expected_output, out
  end

  def strip_indent(str)
    str.gsub(/^ {8}/, "")
  end
end
