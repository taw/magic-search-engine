# Currently all mtgjson base set sizes are correct,
# but this often needs to be done during spoiler season
class PatchBaseSize < Patch
  def call
    sizes = {
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
