require "pathname"

class String
  # WotC's export wraps paragraphs at arbitrary points; almost everything that
  # consumes a rule wants it as a single line.
  def oneline
    gsub(/\s+/, " ")
  end unless method_defined?(:oneline)
end

# Shared handling of WotC's Comprehensive Rules text export, used by
# bin/fetch_comp_rules, bin/format_comp_rules, bin/format_comp_rules_text,
# bin/export_rules_history and bin/comp_rules_history.
module CompRules
  RULES_PATH = Pathname(__dir__) + "../../data/MagicCompRules.txt"
  # bin/export_rules_history dumps every committed version here, one file per
  # commit, described by the manifest.
  HISTORY_DIR = Pathname(__dir__) + "../../tmp/rules"
  MANIFEST_PATH = HISTORY_DIR + "rules-manifest.txt"

  TITLE = "Magic: The Gathering Comprehensive Rules"

  Rule = Struct.new(:id, :text)
  GlossaryEntry = Struct.new(:term, :text)

  # WotC's exports are not consistent about how they encode whitespace:
  # * line breaks within a paragraph are sometimes U+2028, which Ruby does not
  #   treat as a line break at all
  # * lines are sometimes padded with non-breaking spaces, and "blank" lines
  #   are sometimes a lone non-breaking space, which breaks the paragraph
  #   split on /\n{2,}/ - [[:blank:]] covers NBSP, neither \s nor strip do
  # Some early exports (2015-2016) aren't valid UTF-8 either and are Windows-1252.
  def self.normalize(raw)
    utf8 = if raw.dup.force_encoding("UTF-8").valid_encoding?
      raw.dup.force_encoding("UTF-8")
    else
      raw.dup.force_encoding("Windows-1252").encode("UTF-8")
    end
    utf8.tr("\r", "").tr("\u2028\u2029", "\n").gsub(/^[[:blank:]]+|[[:blank:]]+$/, "")
  end

  def self.read(path=RULES_PATH)
    normalize(Pathname(path).binread) # raw bytes, we decide the encoding ourselves
  end

  # Walks the document once, yielding [kind, paragraph] for every block in it.
  # Kinds are :primary_header, :secondary_header, :para, :tos_section, :rule and
  # :glossary_entry. Everything that reads the rules is some fold over this.
  def self.each_block(text)
    return to_enum(:each_block, text) unless block_given?
    paras = normalize(text).split(/\n{2,}/)

    raise "unexpected format: missing title" unless paras[0] == TITLE
    yield :primary_header, paras.shift
    yield :para, paras.shift while paras[0] != "Introduction"
    yield :secondary_header, paras.shift
    yield :para, paras.shift while paras[0] != "Contents"
    yield :secondary_header, paras.shift

    yield :tos_section, paras.shift while paras[0] != "1. Game Concepts"

    yield :rule, paras.shift while paras[0] =~ /\A(\d|Example:)/

    raise "unexpected format: missing glossary" unless paras[0] == "Glossary"
    yield :secondary_header, paras.shift

    yield :glossary_entry, paras.shift while paras[0] != "Credits"

    yield :secondary_header, paras.shift
    yield :para, paras.shift while paras[0]
  end

  # Returns {rules: [Rule...], glossary: [GlossaryEntry...]}
  def self.parse(raw)
    rules = []
    glossary = []
    last_rule = nil

    each_block(raw) do |kind, para|
      case kind
      when :rule
        if para.start_with?("Example:")
          # Examples illustrate the immediately preceding rule, not a rule of
          # their own - fold them into that rule's text so they show up
          # (and diff) together with the rule they belong to.
          last_rule.text = "#{last_rule.text}\n\n#{para.oneline.strip}" if last_rule
          next
        end
        id, body = para.split(" ", 2)
        last_rule = Rule.new(id.strip, body ? body.oneline.strip : "")
        rules << last_rule
      when :glossary_entry
        term, definition = para.split("\n", 2)
        glossary << GlossaryEntry.new(term.strip, definition ? definition.oneline.strip : "")
      end
    end

    {rules: rules, glossary: glossary}
  end
end
