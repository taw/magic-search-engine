class ConditionIsBoosterfun < Condition
  def search(db)
    # Limit booster fun treatments to known sets
    valid_sets = ["eld", "thb", "iko", "m21", "znr", "khm", "stx", "afr", "mid", "vow", "neo", "snc", "dmu", "bro", "one", "2xm", "mh2", "clb", "cmr", "2x2", "dmr", "unf", "bot", "brr"]
	results = Set[]
    db.printings.each do |card_printing|
	  if valid_sets.include?(card_printing.set.code)
	    unless card_printing.foiling == "foilonly"
	      unless card_printing.types.include?("token") or card_printing.types.include?("attraction")
		    case card_printing.set.code # accounts for specific set differences
			when "iko"
			  # Ikoria Godzilla treatments cannot appear in boosters
			  if card_printing.frame_effects.include?("showcase")
			    results << card_printing
			  elsif card_printing.types.include?("planeswalker") and card_printing.border.include?("borderless")
			    results << card_printing
			  end
			when "brr"
			  # Brother's war retro artifacts have blueprint treatments after number 64
			  if card_printing.number.to_i >= 64
			    results << card_printing
			  end
		    else
			  # Typical booster fun treatments
			  if card_printing.frame_effects.include?("showcase") or card_printing.border.include?("borderless") or card_printing.frame == ("old")
		        results << card_printing
			  end
            end
	      end
	    end
	  end
	end
	results
  end

  def to_s
    "is:boosterfun"
  end
end
