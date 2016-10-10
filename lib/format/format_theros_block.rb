class FormatTherosBlock < Format
  def format_pretty_name
    "Theros Block"
  end

  def build_format_sets
    Set["ths", "bng", "jou"]
  end
end
