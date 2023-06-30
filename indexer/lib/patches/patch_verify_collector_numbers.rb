# We need unique identifiers for cards, and generally we use <set_code>/<collector_number>
# This means we must force collector numbers to be unique within each set.
#
# For some sets this isn't true, so we fix them (like planes, vanguard, Unset variants etc.)
#
# For sets without Gatherer numbers we use magiccards.info numbers, as that makes debugging easier.
# Originally it was done for debugging, now mostly because there's no point changing what works.
#
# For cards with multiple printings it's not obvious how to get them arranged so pics match,
# but it's not a huge deal.
#
# By the way ordering by multiverseid would probably be more sensible
# (alpha starts with Ankh of Mishra, not Animate Dead), but compatibilty etc.

class PatchVerifyCollectorNumbers < Patch
  def call
    each_set do |set|
      verify_numbers(set)
    end
  end

  private

  # This breaks the frontend, so it needs to be hard exception
  def verify_numbers(set)
    set_code = set["code"]
    set_name = set["name"]
    cards = cards_by_set[set_code]
    return if cards.empty?
    numbers = cards.map{|c| c["number"]}
    if numbers.compact.size == 0
      warn "Set #{set_code} #{set_name} has no numbers"
    elsif numbers.compact.size != numbers.size
      warn "Set #{set_code} #{set_name} has cards without numbers"
    end
    if numbers.compact.size != numbers.compact.uniq.size
      duplicates = cards
        .group_by{|c| c["number"]}
        .transform_values{|cs| cs.map{|c| c["name"]}}
        .select{|_,cs| cs.size > 1}
      warn "Set #{set_code} #{set_name} has DUPLICATE numbers: #{duplicates.inspect}"
    end
  end
end
