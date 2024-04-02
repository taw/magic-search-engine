class PatchBaseSize < Patch
  def call
    sizes = {
      "jmp" => 78,
      "tsr" => 410, # 289, # THIS IS INCORRECT, need fixes downstream in sealed code
      "dbl" => 534,
      "2x2" => 331,
      "brr" => 126, # nothing printed due to old frame
      "bro" => 287,
      "ltr" => 281, # not printed, "Set size281 + 170"
    }

    sizes.each do |code, size|
      if set_by_code(code)["base_set_size"] == size
        warn "Base set size for #{code} already correct #{size}"
      else
        warn "Patching base set size for #{code} from #{set_by_code(code)["base_set_size"]} to #{size}"
      end
      set_by_code(code)["base_set_size"] = size
    end
  end
end
