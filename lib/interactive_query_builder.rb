class InteractiveQueryBuilder
  def initialize(args={})
    @args = args
  end

  def query
    conds = []
    set_block_conds = []
    @args.each do |cond, keys|
      case cond.to_s
      when "name"
        conds.push *text_and_condition("", keys)
      when "type"
        conds.push *text_and_condition("t:", keys)
      when "oracle"
        conds.push *text_and_condition("o:", keys)
      when "flavor"
        conds.push *text_and_condition("ft:", keys)
      when "artist"
        conds.push *text_and_condition("a:", keys)
      when "rarity"
        conds.push *or_condition(flag_condition("r:", keys))
      when "set"
        set_block_conds.push *flag_condition("e:", keys)
      when "block"
        set_block_conds.push *flag_condition("b:", keys)
      when "watermark"
        if keys.include?("yes")
          conds.push "w:*"
        elsif keys.include?("no")
          conds.push "-w:*"
        else
          conds.push *or_condition(flag_condition("w:", keys))
        end
      else
        raise "Unknown key: #{cond}"
      end
    end

    unless set_block_conds.empty?
      conds.push *or_condition(set_block_conds)
    end
    conds.join(" ")
  end

  private

  def text_and_condition(prefix, keys)
    parse_fragments(keys).map do |frag|
      "#{prefix}#{maybe_quote(frag)}"
    end
  end

  def flag_condition(prefix, keys)
    keys.map do |frag|
      "#{prefix}#{maybe_quote(frag)}"
    end
  end

  def or_condition(conds)
    case conds.size
    when 0
      nil
    when 1
      conds[0]
    else
      "(#{ conds.join(" OR ") })"
    end
  end

  def parse_fragments(str)
    str.scan(/"(.*?)"|(\S+)/).flatten.compact
  end

  def maybe_quote(text)
    if text =~ /\A[a-zA-Z0-9]+\z/
      text
    else
      text.inspect
    end
  end
end
