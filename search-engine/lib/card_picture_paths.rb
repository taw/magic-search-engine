require "digest/sha1"
require "pathname"
require_relative "card_printing"

class Pathname
  def sha1
    Digest::SHA1.hexdigest(read)
  end
end

# Where the card scans live. Repo root relative, because every script that
# touches them is run from the repo root, and because bin/fix_picture_file_capitalization
# compares these against `git mv` targets.
module CardPicturePaths
  LQ_ROOT = Pathname("frontend/public/cards")
  HQ_ROOT = Pathname("frontend/public/cards_hq")

  def self.lq(set_code, number)
    LQ_ROOT + "#{set_code}/#{number}.png"
  end

  def self.hq(set_code, number)
    HQ_ROOT + "#{set_code}/#{number}.png"
  end
end

class CardPrinting
  def path_lq
    CardPicturePaths.lq(set_code, number)
  end

  def path_hq
    CardPicturePaths.hq(set_code, number)
  end

  def path_lq_sha1
    path_lq.sha1 if path_lq.exist?
  end

  def path_hq_sha1
    path_hq.sha1 if path_hq.exist?
  end
end
