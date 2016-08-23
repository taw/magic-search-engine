class InteractiveQueryBuilder
  def initialize(args={})
    @args = args
  end

  def query
    conds = []
    @args.each do |cond, keys|
      case cond.to_s
      when "name"
        parse_fragments(keys).each do |frag|
          conds << maybe_quote(frag)
        end
      when "type"
        parse_fragments(keys).each do |frag|
          conds << "t:#{maybe_quote(frag)}"
        end
      when "oracle"
        parse_fragments(keys).each do |frag|
          conds << "o:#{maybe_quote(frag)}"
        end
      when "flavor"
        parse_fragments(keys).each do |frag|
          conds << "ft:#{maybe_quote(frag)}"
        end
      when "artist"
        parse_fragments(keys).each do |frag|
          conds << "a:#{maybe_quote(frag)}"
        end
      else
        raise "Unknown key: #{cond}"
      end
    end
    conds.join(" ")
  end

  private

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
