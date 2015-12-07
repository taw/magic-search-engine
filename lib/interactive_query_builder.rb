class InteractiveQueryBuilder
  def initialize(args={})
    @args = args
  end

  def query
    conds = []
    @args.each do |cond, keys|
      case cond
      when :any
        fragments = parse_fragments(keys)
        fragments.each do |frag|
          conds << "*:#{maybe_quote(frag)}"
        end
      when :title
        fragments = parse_fragments(keys)
        fragments.each do |frag|
          conds << maybe_quote(frag)
        end
      when :type
        fragments = parse_fragments(keys)
        fragments.each do |frag|
          conds << "t:#{maybe_quote(frag)}"
        end
      when :oracle
        fragments = parse_fragments(keys)
        fragments.each do |frag|
          conds << "o:#{maybe_quote(frag)}"
        end
      when :flavor
        fragments = parse_fragments(keys)
        fragments.each do |frag|
          conds << "ft:#{maybe_quote(frag)}"
        end
      when :artist
        fragments = parse_fragments(keys)
        fragments.each do |frag|
          conds << "a:#{maybe_quote(frag)}"
        end
      else
        raise "Unknown key: #{key}"
      end
    end
    conds.join(" ")
  end

  private

  # TODO: Fix "lol"
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
