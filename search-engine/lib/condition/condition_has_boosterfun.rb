class ConditionHasBoosterfun < Condition
  def initialize()
    @bfun = ConditionIsBoosterfun.new()
  end

  def search(db)
    bf_prints = Set[]
    @bfun.search(db).each do |card_printing|
	  bf_prints << card_printing
	end
    results = Set[]
	bf_prints.each do |main_printing|
	  main_printing.card.printings.each do |sub_print|
	    if sub_print.set.code == main_printing.set.code
		  results << sub_print
		end
	  end
	end
    results
  end
end
