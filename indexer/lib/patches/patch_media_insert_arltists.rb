# Fix missing artists for some Media Inserts
# https://github.com/mtgjson/mtgjson/issues/319
class PatchMediaInsertArtists < Patch
  CORRECT_ARTISTS = {
    "Alhammarret, High Arbiter" => "Richard Wright",
    "Dwynen, Gilt-Leaf Daen" => "Steven Belledin",
    "Hixus, Prison Warden" => "Magali Villenueve",
    "Kothophed, Soul Hoarder" => "Tianhua X",
    "Pia and Kiran Nalaar" => "Tyler Jacobson",
  }
  def call
    each_printing do |card|
      next unless card["set_code"] == "mbp"
      next unless card["artist"] == "???"
      card["artist"] = CORRECT_ARTISTS.fetch(card["name"])
    end
  end
end
