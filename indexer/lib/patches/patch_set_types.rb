class PatchSetTypes < Patch
  def call
    each_set do |set|
      set_code = set["code"]
      set_type = set.delete("type").gsub("_", " ")

      case set["code"]
      when "bbd"
        set_type = "two-headed giant"
      when "mh1"
        set_type = "modern"
      when "cns", "cn2"
        set_type = "conspiracy"
      when "ugl", "unh", "ust"
        set_type = "un"
      end

      set["type"] = set_type
    end
  end
end
