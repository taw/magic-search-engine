# ActiveRecord FTW
# These are all built into modern Ruby, but we keep the shims for old Ruby
# compatibility. Guard each so modern Ruby uses the fast C builtins.
class Hash
  unless method_defined?(:slice)
    def slice(*keys)
      keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
      keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
    end
  end

  unless method_defined?(:compact)
    def compact
      reject{|k,v| v.nil?}
    end
  end

  unless method_defined?(:transform_values)
    def transform_values
      result = {}
      each do |k, v|
        result[k] = yield(v)
      end
      result
    end
  end

  unless method_defined?(:except)
    def except(*keys)
      reject { |k, _| keys.include?(k) }
    end
  end
end
