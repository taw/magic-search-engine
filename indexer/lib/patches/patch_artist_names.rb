class PatchArtistNames < Patch
  def call
    # Prevent slug conflicts
    each_printing do |card|
      unless card["artist"]
        warn "No artist for #{card["name"]} #{card["set_code"]} #{card["number"]}"
        card["artist"] = "unknown"
      end

      card["artist"] = "Jock" if card["artist"] == "JOCK"
      card["artist"] = "Pindurski" if card["artist"] == "PINDURSKI"
    end
  end
end
