class FormatVintage < Format
  def format_pretty_name
    "Vintage"
  end

  def format_sets
    all_sets = Set["mbp", "ptc", "al", "be", "un", "an", "ced", "cedi", "drc", "aq", "rv", "lg", "dk", "fe", "dcilm", "4e", "ia", "ch", "hl", "ai", "rqs", "mr", "mgbc", "itp", "vi", "5e", "pot", "po", "van", "wl", "tp", "sh", "po2", "jr", "ex", "apac", "us", "at", "ul", "6e", "p3k", "ud", "st", "guru", "wrl", "wotc", "mm", "br", "sus", "fnmp", "euro", "ne", "st2k", "pr", "bd", "in", "ps", "7e", "mprp", "ap", "od", "dm", "tr", "ju", "on", "le", "sc", "8e", "mi", "ds", "5dn", "chk", "bok", "sok", "9e", "rav", "thgt", "gp", "cp", "di", "cstd", "cs", "tsts", "ts", "pc", "pro", "gpx", "fut", "10e", "mgdc", "sum", "med", "lw", "evg", "mt", "mlp", "15ann", "shm", "eve", "fvd", "me2", "grc", "ala", "jvc", "cfx", "dvd", "arb", "m10", "fve", "pch", "me3", "zen", "gvl", "pds", "wwk", "pvc", "roe", "dpa", "arc", "m11", "fvr", "ddf", "som", "pd2", "me4", "mbs", "ddg", "nph", "cmd", "m12", "fvl", "ddh", "isd", "pd3", "dka", "ddi", "avr", "pc2", "m13", "v12", "ddj", "rtr", "cma", "gtc", "ddk", "wmcq", "dgm", "mma", "m14", "v13", "ddl", "ths", "c13", "bng", "ddm", "jou", "md1", "cns", "vma", "m15", "clash", "v14", "ddn", "ktk", "c14", "ddaevg", "ddadvd", "ddagvl", "ddajvc", "ugin", "frf", "ddo", "dtk", "tpr", "mm2", "ori", "v15", "ddp", "bfz", "exp", "c15", "ogw", "ddq", "w16", "soi", "ema", "emn"]
    if @time and @time < Date.parse("2005.3.20")
      all_sets - Set["pot", "po", "po2", "p3k", "st", "st2k"]
    else
      all_sets
    end
  end
end
