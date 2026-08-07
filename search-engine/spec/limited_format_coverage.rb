require "yaml"
require "pathname"

# Which limited formats a set ought to have, judging by the boosters it has.
# Only limited_format_coverage_spec uses this, so it lives here and not in lib.
# A set with a draft booster was drafted, a set with a prerelease booster had a
# prerelease, and from Alara Reborn on a set that was drafted was also played
# as six booster sealed.
#
# data/limited_formats/ is filled in by hand out of old primers and
# mtg.wiki, so it lags behind new sets, and everything here is a warning only.
# Sets which had the boosters but never had the format go into
# data/limited_formats_not_played.yaml, with a note saying why.
class LimitedFormatCoverage
  NOT_PLAYED_PATH = Pathname(__dir__) + "../../data/limited_formats_not_played.yaml"

  # Booster a set has => format it should have. Older sets just have a booster
  # named after the set, and we make no claims about those - drafting them was
  # never an event WotC ran. A set whose boosters are Magic Online only was
  # drafted there and nowhere else. Magic Arena has its own boosters, and a
  # draft out of them is its own format, even for sets printed on paper.
  DRAFT_BOOSTERS = {
    "draft" => "draft",
    "play" => "draft",
    "mtgo" => "mtgo-draft",
    "arena" => "arena-draft",
    "play-arena" => "arena-draft",
  }

  # Sealed used to be one tournament pack plus boosters, and we have no data
  # for that era, so only sets from Alara Reborn on are expected to have it.
  # https://mtg.wiki/page/Sealed_Deck
  FIRST_SIX_BOOSTER_SEALED_DATE = Date.parse("2009-04-30")

  def initialize(db)
    @db = db
  end

  # Set code => booster variants it has, like "draft" or "prerelease-azorius"
  def booster_variants
    @booster_variants ||= @db.unique_supported_booster_types
      .group_by{|code, booster| booster.set_code}
      .transform_values{|boosters| boosters.map{|code, booster| code.split("-", 2)[1].to_s}}
  end

  # [set code, format] pairs the boosters of a set tell us it should have
  def expected_formats
    booster_variants.flat_map do |set_code, variants|
      formats = variants.filter_map{|variant| draft_format_of(variant)}
      # The sealed we track is a paper event, so digital only sets don't get it
      formats << "sealed" if formats.include?("draft") and six_booster_sealed_era?(set_code)
      formats << "prerelease-sealed" if variants.any?{|variant| variant.start_with?("prerelease")}
      formats.uniq.map{|format| [set_code, format]}
    end
  end

  def missing_formats
    expected_formats.reject{|set_code, format|
      @db.sets[set_code].limited_formats.any?{|limited_format| limited_format.type == format} or
        not_played.dig(set_code, format)
    }.sort
  end

  def missing_formats_warning
    missing = missing_formats
    return nil if missing.empty?
    "These sets should probably have limited formats we don't have: " +
      missing.map{|set_code, format| "#{set_code} #{format}"}.join(", ") +
      " - fill them in in data/limited_formats/<set>.yaml," \
      " or say why they never happened in data/limited_formats_not_played.yaml"
  end

  # A set is always drafted with its own boosters, even in a block draft where
  # most of the packs come from the older sets of the block
  def drafts_without_own_boosters
    @db.limited_formats.select{|limited_format|
      limited_format.format_type == "draft" and
        limited_format.booster_order.none?{|pack| pack.set_code == limited_format.set_code}
    }
  end

  def drafts_without_own_boosters_warning
    drafts = drafts_without_own_boosters
    return nil if drafts.empty?
    "These drafts don't open a single booster of their own set: " +
      drafts.map{|limited_format| limited_format.set_code}.join(" ") +
      " - check their booster order in data/limited_formats/<set>.yaml"
  end

  # Every prerelease booster a set has is a booster somebody was handed at that
  # prerelease, so the pool should be using it
  def unused_prerelease_boosters
    @db.limited_formats.flat_map{|limited_format|
      next [] unless limited_format.type == "prerelease-sealed"
      used = limited_format.pools.flat_map{|pool|
        pool.boosters.map{|count, pack| pack.code} +
          pool.random_boosters.flat_map{|random| random.packs.map(&:code)}
      }
      prerelease_boosters_of(limited_format.set_code) - used
    }
  end

  def unused_prerelease_boosters_warning
    unused = unused_prerelease_boosters
    return nil if unused.empty?
    "These prerelease boosters are not handed out by any prerelease pool: " +
      unused.join(" ") +
      " - somebody got them, so add them in data/limited_formats/<set>.yaml"
  end

  # Set code => format => why that set never had that format
  def not_played
    @not_played ||= YAML.load_file(NOT_PLAYED_PATH)
  end

  # Exceptions for formats a set actually has are just stale data
  def stale_not_played
    not_played.flat_map{|set_code, formats|
      set = @db.sets[set_code]
      next [] unless set
      formats.keys
        .select{|format| set.limited_formats.any?{|limited_format| limited_format.type == format}}
        .map{|format| [set_code, format]}
    }
  end

  private

  # A set whose Arena boosters changed from run to run has one numbered
  # booster and one numbered format per run: sir-arena-2 => arena-draft-2
  def draft_format_of(variant)
    return DRAFT_BOOSTERS[variant] if DRAFT_BOOSTERS[variant]
    "arena-draft-#{$1}" if variant =~ /\Aarena-(\d+)\z/
  end

  def prerelease_boosters_of(set_code)
    booster_variants[set_code]
      .select{|variant| variant.start_with?("prerelease")}
      .map{|variant| "#{set_code}-#{variant}"}
  end

  def six_booster_sealed_era?(set_code)
    release_date = @db.sets[set_code].release_date
    release_date && release_date >= FIRST_SIX_BOOSTER_SEALED_DATE
  end
end
