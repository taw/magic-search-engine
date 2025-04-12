class TokenUuidsSerializer
  def initialize(tokens)
    @tokens = tokens
  end

  def inspect
    "#{self.class}"
  end

  def to_s
    @tokens
      .map{|token| [token["set"]["code"], token["number"], token["uuid"], token["name"]] }
      .sort_by{|sc,n,u,name| [sc, n.to_i, n, name, u || ""] }
      .map{|row| row.join("\t") + "\n" }
      .join
  end
end
