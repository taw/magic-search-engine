require "rspec/core/formatters"

# Progress dots without a summary, for workers under bin/parallel_rspec.
# Several workers share one terminal, so only the parent gets to report totals.
class WorkerProgressFormatter
  RSpec::Core::Formatters.register self, :example_passed, :example_failed, :example_pending

  def initialize(output)
    @output = output
  end

  def example_passed(_notification)
    write "."
  end

  def example_failed(_notification)
    write "F"
  end

  def example_pending(_notification)
    write "*"
  end

  private

  # Single writes of a single byte, so dots from different workers interleave
  # rather than tearing.
  def write(char)
    @output.write(char)
    @output.flush
  end
end
