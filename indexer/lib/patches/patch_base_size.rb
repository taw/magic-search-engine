class PatchBaseSize < Patch
  def call
    # https://github.com/mtgjson/mtgjson/issues/765
    # https://github.com/mtgjson/mtgjson/issues/855
    sizes = {
      # "afc" => 62,
      # "akr" => 338, # 339 is box topper, set has A/Bs too
      # "c20" => 322,
      # "c21" => 81,
      # "cmr" => 361,
      "jmp" => 78,
      # "khm" => 285,
      # "klr" => 301, # 302 is box topper
      # "m21" => 274,
      # "sta" => 63,
      "tsr" => 410, # 289, # THIS IS INCORRECT, need fixes downstream in sealed code
      # "und" => 96,
      # "znr" => 280,
      # "vow" => 277,
      "dbl" => 534,
    }

    sizes.each do |code, size|
      if set_by_code(code)["base_set_size"] == size
        warn "Base set size for #{code} already correct #{size}"
      else
        warn "Pathing base set size for #{code} from #{set_by_code(code)["base_set_size"]} to #{size}"
      end
      set_by_code(code)["base_set_size"] = size
    end
  end
end
