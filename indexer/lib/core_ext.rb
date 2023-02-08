# ActiveRecord FTW
class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end

  def compact
    reject{|k,v| v.nil?}
  end

  def transform_values
    result = {}
    each do |k, v|
      result[k] = yield(v)
    end
    result
  end

  unless method_defined?(:except)
    def except(*keys)
      reject { |k, _| keys.include?(k) }
    end
  end
end
