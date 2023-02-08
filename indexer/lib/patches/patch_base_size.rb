class PatchBaseSize < Patch
  def call
    # https://github.com/mtgjson/mtgjson/issues/765
    # https://github.com/mtgjson/mtgjson/issues/855
    sizes = {
      "jmp" => 78,
      "tsr" => 410, # 289, # THIS IS INCORRECT, need fixes downstream in sealed code
      "dbl" => 534,
      "2x2" => 331,
      "dmu" => 281,
      "brr" => 126, # nothing printed due to old frame
      "bro" => 287,
      "dmr" => 261,
      "one" => 271,
      "onc" => 28,
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
