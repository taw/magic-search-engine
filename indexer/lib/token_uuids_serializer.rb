class TokenUuidsSerializer
  def initialize(tokens)
    @tokens = tokens
  end

  def inspect
    "#{self.class}"
  end

  def to_s
    @tokens
      .map{|token| token_data(token) }
      .sort_by{|sc,n,u,name| [sc, n.to_i, n, name, u || ""] }
      .map{|row| row.join("\t") + "\n" }
      .join
  end

  def token_data(token)
    [
      token["set"]["code"],
      token["setCode"]&.downcase,
      token["number"],
      token["uuid"],
      token["faceName"] || token["name"],
    ]
  end
end
