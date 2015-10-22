class FormatModern < Format
  def format_name
    "modern"
  end

  def format_sets
    @format_sets ||= Set["8e", "mi", "ds", "5dn", "chk", "bok", "sok", "9e", "rav", "gp", "di", "cs", "ts", "tsts", "pc", "fut", "10e", "lw", "mt", "shm", "eve", "ala", "cfx", "arb", "m10", "zen", "wwk", "roe", "m11", "som", "mbs", "nph", "m12", "isd", "dka", "avr", "m13", "rtr", "gtc", "dgm", "m14", "ths", "bng", "jou", "m15", "ktk", "frf", "dtk", "ori", "bfz"]
  end
end
