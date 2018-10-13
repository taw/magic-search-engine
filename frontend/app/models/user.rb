require "json"
require "pathname"

class User < ApplicationRecord
  validates_presence_of :uid
  validates_uniqueness_of :uid

  def self.find_or_create_from_hash(hash)
    find_or_create_by!(uid: hash['uid'])
  end

  def profile_data
    user_path = Pathname.new("/var/www/loreseeker.fenhl.net/profiles").children.flat_map do |guild_dir|
      user_path = guild_dir + "#{self.uid}.json"
      if user_path.exist?
        [user_path]
      else
        []
      end
    end.first
    JSON.load(user_path)
  end

  def username
    profile_data["username"]
  end

  def discrim
    profile_data["discriminator"]
  end

  def to_s
    "#{self.username}##{self.discrim}"
  end
end
