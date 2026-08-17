require "rails_helper"

RSpec.describe HelpHelper, type: :helper do
  # Every line of the syntax page is one of these
  it "renders an example query with its explanation" do
    expect(helper.search_help("mana>={2}{R}", "Cards with mana cost at least {2}{R}")).to eq(
      %[<li>Cards with mana cost at least <span class="manacost">] +
      %[<span class="mana mana-cost mana-2"><span class="sr-only">{2}</span></span>] +
      %[<span class="mana mana-cost mana-r"><span class="sr-only">{R}</span></span>] +
      %[</span> - ] +
      %[<a href="/card?q=mana%3E%3D%7B2%7D%7BR%7D">mana&gt;={2}{R}</a></li>]
    )
  end

  it "escapes the query it shows" do
    expect(helper.search_help("t:<script>", "Nope")).to include "&lt;script&gt;"
  end
end
