# This should probably be multiple patches
# Also this whole file will need full rewrite for v4 migration
class PatchFixCollectorNumbers < Patch
  def call
    warn "This file should get removed after v4 migration is complete"
    each_set do |set|
      fix_numbers(set)
    end
  end

  private

  def fix_numbers(set)
    set_code = set["code"]
    set_name = set["name"]
    cards = cards_by_set[set_code]

    case set_code
    # These are somewhat silly orders
    when "s00"
      cards
        .sort_by{|c| [c["name"], c["multiverseid"]] }
        .each_with_index{|c,i| c["number"] = "#{i+1}"}
    end
  end
end
