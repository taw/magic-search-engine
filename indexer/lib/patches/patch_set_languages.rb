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

  OVERRIDE = {
    # Promos in non-regular language
    "pinv" => ["en"], # Latin
    "ppls" => ["en"], # Ancient Greek
    "papc" => ["en"], # Sanskrit
    "pody" => ["en"], # Arabic
    "pjud" => ["en"], # Hebrew
    "j14" => ["en"], # Phyrexian
    "pw23" => ["en"], # Phyrexian

    # No good source
    "mb1" => ["en"],

    # https://magic.wizards.com/en/news/feature/challenger-decks-lists-2018-02-23
    "q01 Challenger Decks 2018" => ["en", "jp"],

    # https://magic.wizards.com/en/news/feature/challenger-decks-2019-03-18
    # These decks will be available worldwide in English, with Japanese available in Japan.
    "q02 Challenger Decks 2019" => ["en"],
    "q03 Challenger Decks 2019 Japan" => ["jp"],

    # https://magic.wizards.com/en/news/feature/challenger-decks-2020-02-15
    # These decks will be available worldwide in English, with Japanese available in Japan.
    "q04 Challenger Decks 2020" => ["en", "jp"],

    # https://magic.wizards.com/en/news/feature/challenger-decks-2021-02-12
    # These decks will be available worldwide in English, with Japanese available in Japan.
    "q05 Challenger Decks 2021" => ["en", "jp"],

    # https://magic.wizards.com/en/news/feature/challenger-decks-2022
    # These latest Challenger Decks will be available worldwide in English, with German, French, and Japanese languages available in their respective regions.
    "q08 Pioneer Challenger Decks 2022" => ["en", "de", "fr", "jp"],
  }.to_h{|sc,ls| [sc.split.first, ls]}

  def call
    each_set do |set|
      set_code = set["code"]
      set_desc = "Set #{set["code"]} #{set["name"]}"

      if OVERRIDE[set_code]
        set["languages"] = OVERRIDE[set_code]
        next
      end

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
