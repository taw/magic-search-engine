class PatchArtistNames < Patch
  def call
    # Prevent slug conflicts
    each_printing do |card|
      unless card["artist"]
        unless card["name"] == "Look at Me, I'm R&D"
          warn "No artist for #{card["name"]} #{card["set_code"]} #{card["number"]}"
        end
        card["artist"] = "unknown"
      end
    end
  end
end
