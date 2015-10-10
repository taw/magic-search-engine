require_relative "test_helper"

class CardDatabaseRTRTest < Minitest::Test
  def setup
    @db = CardDatabase.new(Pathname(__dir__) + "index/rtr_block.json")
  end

  def test_filter_colors_multicolored
    assert false
  end
end
