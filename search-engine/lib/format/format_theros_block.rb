class FormatTherosBlock < Format
  def format_pretty_name
    "Theros Block"
  end

  def format_start_date
    "2013-09-27"
  end

  def build_included_sets
    Set["ths", "bng", "jou"]
  end
end
