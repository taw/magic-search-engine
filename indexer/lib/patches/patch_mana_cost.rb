# Fix loyalty symbols from +1 to [+1] etc. so they can be displayed in a pretty way
class PatchManaCost < Patch
  def call
    each_printing do |card|
      next unless card["manaCost"]
      card["manaCost"] = card["manaCost"].downcase
    end
  end
end
