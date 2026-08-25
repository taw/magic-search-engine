# Shims for Ruby versions older than the newest we support.
# Guard each so newer Ruby uses the fast C builtin.
class Hash
  # Builtin since Ruby 3.0; needed for 2.6 and 2.7.
  unless method_defined?(:except)
    def except(*keys)
      reject { |k, _| keys.include?(k) }
    end
  end
end
