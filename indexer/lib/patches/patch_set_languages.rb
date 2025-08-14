class PatchSetLanguages < Patch
  LANGUAGES = {
    # "Ancient Greek",
    # "Arabic",
    "Chinese Simplified" => "cn",
    "Chinese Traditional" => "cs",
    "English" => "en",
    "French" => "fr",
    "German" => "de",
    # "Hebrew",
    "Italian" => "it",
    "Japanese" => "jp",
    "Korean" => "kr",
    # "Latin",
    # "Phyrexian",
    "Portuguese (Brazil)" => "pt",
    "Russian" => "ru",
    # "Sanskrit",
    "Spanish" => "sp",
  }

  def call
    each_set do |set|
      set_desc = "Set #{set["code"]} #{set["name"]}"

      if set["languages"].nil?
        warn "#{set_desc} has no language information. Defaulting to English-only."
        set["languages"] = ["en"]
        next
      end

      weird_languages = set["languages"] - LANGUAGES.keys
      unless weird_languages.empty?
        warn "#{set_desc} has weird languages #{weird_languages.join(", ")}, skipping extra languages."
      end

      normal_languages = set["languages"] & LANGUAGES.keys
      if normal_languages.empty?
        warn "#{set_desc} has only weird languages, defaulting to English-only"
        set["languages"] = ["en"]
      else
        set["languages"] = normal_languages.map{|l| LANGUAGES[l]}.sort
      end
    end
  end
end
