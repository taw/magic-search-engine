# They're just a way to apply Oracle corrections, they shouldn't be actually included
# so delete them once they've done their job
class PatchDeleteErrataSets < Patch
  def call
    delete_printing_if do |card|
      card["set"]["types"].include?("errata")
    end

    @sets.delete_if do |set|
      set["types"].include?("errata")
    end
  end
end
