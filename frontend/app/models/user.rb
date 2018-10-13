class User < ApplicationRecord
  validates_presence_of :uid
  validates_uniqueness_of :uid

  def self.find_or_create_from_hash(hash)
    find_or_create_by!(uid: hash['uid'])
  end
end
