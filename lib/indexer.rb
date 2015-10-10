# ActiveRecord FTW
class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end
end

class Pathname
  def write_at(content)
    parent.mkpath
    write(content)
  end
end

class Indexer
  def initialize
    json_path = Pathname(__dir__) + "../data/AllSets-x.json"
    @data = JSON.parse(json_path.read)
    @data.each do |set_code, set|
      set["cards"].each do |card|
        card.delete "imageName"
        card.delete "printings"
        card.delete "id"
        card.delete "multiverseid"
        card.delete "rulings"
        card.delete "foreignNames"
      end
    end
  end

  def save_all!(path)
    path = Pathname(path)
    path.parent.mkpath
    path.write(@data.to_json)
  end

  def save_subset!(path, *sets)
    path = Pathname(path)
    path.parent.mkpath
    path.write(@data.slice(*sets).to_json)
  end
end
