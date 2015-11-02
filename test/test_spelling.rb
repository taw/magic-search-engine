require_relative "test_helper"

class SpellingTest < Minitest::Test
  def setup
    @db = load_database
  end

  def test_spelling
    assert_spelling_suggestions "kolagan", "kolaghan"
    # if distance 1 match, only display that, not distance 2
    assert_spelling_suggestions "SHANDRA", "chandra"
    # if not, display all distance 2 matches
    assert_spelling_suggestions "SHANDRAA", "chandra", "shandlar"
    assert_spelling_suggestions "Ajuni", "ajani"
    assert_spelling_suggestions "Ætherise", "aetherize"
    assert_spelling_suggestions "ajuni's", "ajani"
  end

  def assert_spelling_suggestions(word, *expected_suggestions)
    actual_suggestions = @db.suggest_spelling(word)
    assert_equal expected_suggestions, actual_suggestions, "Spelling suggestions for #{word}"
  end
end
