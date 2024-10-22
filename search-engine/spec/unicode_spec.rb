describe "Unicode Normalization" do
  include_context "db"

  let(:letters_with_accents) do
    db.printings.flat_map{|c|
      [c.name, c.text, c.flavor, c.artist_name]
        .join
        .scan(/[\p{Letter}&&\p{Latin}&&[^a-zA-Z]]/)
        .uniq
    }.uniq.sort
  end
  let(:letters_in_all_cases) do
    letters_with_accents.flat_map{|l| [l, l.upcase, l.downcase]}.uniq.sort
  end

  it "normalizes all Unicode characters" do
    letters_in_all_cases.each do |letter|
      case letter
      when "œ"
        letter.normalize_accents.should eq("oe")
      when "Œ"
        letter.normalize_accents.should eq("Oe")
      when "ı"
        letter.normalize_accents.should eq("i")
      else
        letter.normalize_accents.should match(/\A[a-zA-Z]\z/)
        letter.normalize_accents.should eq(letter.unicode_normalize(:nfd).gsub(/[^A-Za-z]/, ""))
      end
    end
  end

  it "deals with Polish letters" do
    assert_search_equal "a:wuzyk", "a:wużyk"
  end
end
