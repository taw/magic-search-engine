# VMA is sort of fake
# as far as I can tell it was modern frames at release, but it's m15 frames now
# and we have it scanned in m15 frames
#
# There were promos between VMA and M15 with M15 frames, so at least it fixes this issue
class PatchFrame < Patch
  def call

    each_set do |set|
      set["frame"] = begin
        if set["code"] == "tsb"
          "old"
        else
          frame_by_release_date(set["release_date"])
        end
      end
    end

    each_printing do |card|
      if card["set_code"] == "fut" and card["timeshifted"]
        card["frame"] = "future"
      elsif card["release_date"]
        card["frame"] = frame_by_release_date(card["release_date"])
      end
    end
  end

  def frame_by_release_date(release_date)
    eight_edition_release_date = "2003-07-28"
    vma_release_date = "2014-06-16"
    if release_date < eight_edition_release_date
      "old"
    elsif release_date < vma_release_date
      # Were there any 8e+ old frame printings?
      "modern"
    else
      "m15"
    end
  end
end
