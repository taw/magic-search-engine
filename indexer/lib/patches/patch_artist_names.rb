class PatchArtistNames < Patch
  def call
    # Prevent slug conflicts
    each_printing do |card|
      unless card["artist"]
        warn "No artist for #{card["name"]} #{card["set_code"]} #{card["number"]}"
        card["artist"] = "unknown"
      end
    end
  end
end
