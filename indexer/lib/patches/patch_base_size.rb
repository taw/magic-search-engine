class PatchBaseSize < Patch
  def call
    # https://github.com/mtgjson/mtgjson/issues/765
    set_by_code("m21")["base_set_size"] = 274
    set_by_code("znr")["base_set_size"] = 280
    set_by_code("khm")["base_set_size"] = 285
  end
end
