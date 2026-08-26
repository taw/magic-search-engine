# Shims for Ruby versions older than the newest we support.
# Guard each so newer Ruby uses the fast C builtin.
class Set
  # Builtin since Ruby 3.0; needed for 2.7.
  unless method_defined?(:join)
    def join(separator=nil)
      to_a.join(separator)
    end
  end
end
