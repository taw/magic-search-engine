# Shims for Ruby versions older than the newest we support.
# Guard each so newer Ruby uses the fast C builtin.
module Enumerable
  # Builtin since Ruby 2.7; needed for 2.6.
  unless method_defined?(:filter_map)
    def filter_map
      return to_enum(:filter_map) unless block_given?
      each_with_object([]) do |element, result|
        value = yield(element)
        result << value if value
      end
    end
  end
end
