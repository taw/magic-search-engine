# This class represents card from index point of view, not from data point of view
# (thinking in solr/lucene terms)
require "date"
require_relative "ban_list"
require_relative "legality_information"

class Card
  ABILITY_WORD_LIST = [
    # Normal
    "Adamant",
    "Addendum",
    "Alliance",
    "Battalion",
    "Bloodrush",
    "Celebration",
    "Channel",
    "Chroma",
    "Cohort",
    "Constellation",
    "Converge",
    "Corrupted",
    "Council's dilemma",
    "Coven",
    "Delirium",
    "Domain",
    "Eminence",
    "Enrage",
    "Everypony's Invited",
    "Family Gathering",
    "Fateful hour",
    "Ferocious",
    "Formidable",
    "Gotcha",
    "Grandeur",
    "Hellbent",
    "Hero's Reward",
    "Heroic",
    "Imprint",
    "Inspired",
    "Join forces",
    "Kinfall",
    "Kinship",
    "Landfall",
    "Landship",
    "Legacy",
    "Lieutenant",
    "Magecraft",
    "Metalcraft",
    "Morbid",
    "Parley",
    "Radiance",
    "Raid",
    "Rally",
    "Requirement",
    "Revolt",
    "Secret council",
    "Sonic Rainboom",
    "Spell mastery",
    "Strive",
    "Sweep",
    "Teamwork",
    "Tempting offer",
    "Threshold",
    "Underdog",
    "Undergrowth",
    "Will of the council",
    "Will of the Planeswalkers",
    # AFR flavor words
    "Acid Breath",
    "Animate Walking Statue",
    "Beacon of Hope",
    "Bear Form",
    "Bewitching Whispers",
    "Binding Contract",
    "Circle of Death",
    "Climb Over",
    "Cold Breath",
    "Combat Inspiration",
    "Cone of Cold",
    "Cunning Action",
    "Dark One's Own Luck",
    "Displacement",
    "Dissolve",
    "Divine Intervention",
    "Dominate Monster",
    "Drag Below",
    "Engulf",
    "Fire Breath",
    "Flurry of Blows",
    "Grant an Advantage",
    "Invoke Duplicity",
    "Keen Senses",
    "Life Drain",
    "Lightning Breath",
    "Mage Hand",
    "Magical Tinkering",
    "Pack tactics",
    "Poison Breath",
    "Psionic Spells",
    "Rappel Down",
    "Rejuvenation",
    "Search the Room",
    "Siege Monster",
    "Sneak Attack",
    "Split",
    "Stunning Strike",
    "Tail Spikes",
    "Teleport",
    "Tie Up",
    "Tragic Backstory",
    "Whirlwind",
    "Whispers of the Grave",
    "Wild Magic Surge",
    # AFR Dungeon Rooms
    "Cave Entrance",
    "Cradle of the Death God",
    "Dark Pool",
    "Deep Mines",
    "Dungeon Level",
    "Fungi Cavern",
    "Goblin Bazaar",
    "Goblin Lair",
    "Lost Level",
    "Mad Wizard's Lair",
    "Mine Tunnels",
    "Muiral's Graveyard",
    "Oubliette",
    "Runestone Caverns",
    "Sandfall Cell",
    "Storeroom",
    "Temple of Dumathoin",
    "Trapped Entry",
    "Twisted Caverns",
    "Veils of Fear",
    "Yawning Portal",
    # AFC flavor words
    "Astral Projection",
    "Berserk",
    "Create Undead",
    "Focus Beam",
    "Mystic Arcanum",
    "Negative Energy Cone",
    "Pact Boon",
    "Perfect Illumination",
    # SLD Street Fighter
    # These are printed on actual cards, but not on their SLX equivalents
    # so Oracle doesn't include any of them
    # "Electric Thunder",
    # "Fierce Punch",
    # "Hadoken",
    # "Hundred Hand Slap",
    # "Iron Muscle",
    # "Lightning Kick",
    # "Rolling Attack",
    # "Shoryuken",
    # "Spinning Piledriver",
    # "Sumo Spirit",
    # CLB flavor words
    "Aberrant Tinkering",
    "Animate Chains",
    "Avoidance",
    "Bigby's Hand",
    "Blood Drain",
    "Body Thief",
    "Ceremorphosis",
    "Confounding Clouds",
    "Conjure Elemental",
    "Crown of Madness",
    "Devour Intellect",
    "Enthralling Performance",
    "Gathered Swarm",
    "Gust of Wind",
    "Hive Mind",
    "Homunculus Servant",
    "Horrific Symbiosis",
    "Infesting Spores",
    "Keen Sight",
    "Loud Ruckus",
    "Lure the Unwary",
    "Mama's Coming",
    "Mantle of Inspiration",
    "Mold Earth",
    "Mold Harvest",
    "Natural Recovery",
    "Natural Shelter",
    "Probing Telepathy",
    "Project Image",
    "Protection Fighting Style",
    "Psychic Blades",
    "Psychic Defense",
    "Scorching Ray",
    "Sleight of Hand",
    "Spiked Retribution",
    "Toxic Spores",
    "Vicious Mockery",
    "Weird Insight",
    "Wind Walk",
    # HBG flavor words
    "Calim's Breath",
    "Gift of Tiamat",
    "Molting Exoskeleton",
    "Psionic Adept",
    "Rage Beyond Death",
    "Wild Shape",
    # CLB Dungeon
    "Archives",
    "Arena",
    "Catacombs",
    "Forge",
    "Lost Well",
    "Secret Entrance",
    "Stash",
    "Throne of the Dead Three",
    # 40K
    "A Thousand Souls Die Every Day",
    "Advanced Species",
    "Aegis of the Emperor",
    "Allure of Slaanesh",
    "Architect of Deception",
    "Armour of Shrieking Souls",
    "Atomic Transmutation",
    "Battle Cannon",
    "Benediction of the Omnissiah",
    "Berzerker",
    "Blade of Magnus",
    "Blood Chalice",
    "Brood Telepathy",
    "Chainsword",
    "Chapter Master",
    "Children of the Cult",
    "Command Protocols",
    "Command Section",
    "Concealed Position",
    "Coruscating Flames",
    "Crushing Teeth",
    "Curse of the Walking Pox",
    "Daemon Sword",
    "Death Frenzy",
    "Devastating Charge",
    "Devourer of Souls",
    "Devouring Monster",
    "Drain Life",
    "Dynastic Advisor",
    "Dynastic Codes",
    "Dynastic Command Node",
    "Echo of the First Murder",
    "Elite Troops",
    "Endless Swarm",
    "Endurant",
    "Enmitic Exterminator",
    "Eternity Gate",
    "Exile Cannon",
    "Fabricator Claw Array",
    "Fallen Warrior",
    "Fast Healing",
    "Feeder Mandibles",
    "Field Reprogramming",
    "Fire of Tzeentch",
    "Flesh Flayer",
    "Flesh Hooks",
    "Frenzied Metabolism",
    "Frenzied Rampage",
    "Gatling Blaster",
    "Genestealer's Kiss",
    "Genomic Enhancement",
    "Gift of Chaos",
    "Grand Strategist",
    "Guardian Protocols",
    "Harbinger of Despair",
    "Healing Tears",
    "Heavy Power Hammer",
    "Heavy Rock Cutter",
    "Hunt for Heresy",
    "Hyperphase Threshers",
    "Hypertoxic Miasma",
    "Inquisition Agents",
    "Invasion Beams",
    "Jolly Gutpipes",
    "Leading from the Front",
    "Locus of Slaanesh",
    "Lord of Chaos",
    "Lord of Torment",
    "Lord of the Pyrrhian Legions",
    "Mark of Chaos Ascendant",
    "Martyrdom",
    "Master Tactician",
    "Master of Machines",
    "Matter Absorption",
    "Medicus Ministorum",
    "My Will Be Done",
    "Neurotraumal Rod",
    "Phaeron",
    "Phalanx Commander",
    "Pheromone Trail",
    "Plasma Incinerator",
    "Polymorphine",
    "Praesidium Protectiva",
    "Primarch of the Death Guard",
    "Prince of Chaos",
    "Prismatic Gallery",
    "Proclamator Hailer",
    "Protector",
    "Psychic Abomination",
    "Psychic Stimulus",
    "Rapacious Hunger",
    "Rapid Regeneration",
    "Relentless March",
    "Repair Barge",
    "Reverberating Summons",
    "Rites of Banishment",
    "Rogue Trader",
    "Rosarius",
    "Rot Fly",
    "Ruinous Ascension",
    "Sarcophagus",
    "Scavenge the Dead",
    "Secrets of the Soul",
    "Shieldwall",
    "Shrieking Gargoyles",
    "Sigil of Corruption",
    "Skilled Outrider",
    "Skyswarm",
    "Sonic Blaster",
    "Sorcerous Elixir",
    "Sorcerous Inspiration",
    "Spawn Termagants",
    "Spear of the Void Dragon",
    "Spiritual Leader",
    "Spore Chimney",
    "Stowage",
    "Strategic Coordinator",
    "Subterranean Assault",
    "Summary Execution",
    "Suppressing Fire",
    "Symphony of Pain",
    "Synapse Creature",
    "Synaptic Disintegrator",
    "Targeting Relay",
    "Terror from the Deep",
    "The Betrayer",
    "The Will of the Hive Mind",
    "Three Autostubs",
    "Titanic",
    "Transdimensional Scout",
    "Translocation Protocols",
    "Ultima Founding",
    "Unearthly Power",
    "Unquestionable Wisdom",
    "Vanguard Species",
    "Veil of Time",
    "Void Shields",
    "Warp Blast",
    "Warp Vortex",
    "Wraith Form",
    "Xenos Cunning",
  ].sort
  ABILITY_WORD_RX = %r[^(#{Regexp.union(ABILITY_WORD_LIST)}) —]i

  attr_reader :data, :printings
  attr_writer :printings # For db subset

  attr_reader(
    :alchemy,
    :augment,
    :brawler,
    :cmc,
    :color_identity_set,
    :color_identity,
    :color_indicator_set,
    :color_indicator,
    :colors_set,
    :colors,
    :commander,
    :decklimit,
    :defense,
    :display_mana_cost,
    :display_power,
    :display_toughness,
    :extra,
    :foreign_names_normalized,
    :foreign_names,
    :fulltext_normalized,
    :fulltext,
    :funny,
    :hand,
    :has_alchemy,
    :in_spellbook,
    :keywords,
    :layout,
    :life,
    :loyalty,
    :mana_cost,
    :mana_hash,
    :name,
    :names,
    :power,
    :related,
    :reminder_text,
    :reserved,
    :rulings,
    :specialized,
    :specializes,
    :spellbook,
    :stemmed_name,
    :text_normalized,
    :text,
    :toughness,
    :typeline,
    :types,
  )

  def initialize(data)
    @printings = []
    @name = data["name"]
    @stemmed_name = -@name.downcase.normalize_accents.gsub(/s\b/, "").tr("-", " ")
    @names = data["names"]
    @layout = data["layout"]
    @colors = data["colors"] || ""
    @colors_set = @colors.chars.to_set
    @color_identity = data["ci"]
    @color_identity_set = @color_identity.chars.to_set
    @funny = data["funny"]
    @fulltext = -(data["text"] || "")
    @fulltext_normalized = -@fulltext.normalize_accents
    @text = @fulltext
    @text = @text.gsub(/\s*\([^\(\)]*\)/, "") unless @funny or @layout == "dungeon"
    @text = -@text.sub(/\s*\z/, "").gsub(/ *\n/, "\n").sub(/\A\s*/, "")
    @text_normalized = -@text.normalize_accents
    @augment = !!(@text =~ /augment \{/i)
    @mana_cost = data["manaCost"]
    @reserved = data["reserved"] || false
    @types = ["types", "subtypes", "supertypes"]
      .flat_map{|t| data[t] || []}
      .map{|t| -t.downcase.tr("’\u2212", "'-").gsub("'s", "").tr(" ", "-")}
    @cmc = data["cmc"] || 0
    @power = data["power"] ? smart_convert_powtou(data["power"]) : nil
    @toughness = data["toughness"] ? smart_convert_powtou(data["toughness"]) : nil
    @loyalty = data["loyalty"] ? smart_convert_powtou(data["loyalty"]) : nil
    @display_power = data["display_power"] ? data["display_power"] : @power
    @display_toughness = data["display_toughness"] ? data["display_toughness"] : @toughness
    @display_mana_cost = data["hide_mana_cost"] ? nil : @mana_cost
    @alchemy = data["alchemy"]
    @has_alchemy = data["has_alchemy"]
    if ["vanguard", "planar", "scheme"].include?(@layout) or @types.include?("conspiracy") or @alchemy
      @extra = true
    else
      @extra = false
    end
    @decklimit = data["decklimit"]
    @hand = data["hand"]
    @life = data["life"]
    @rulings = data["rulings"]
    @secondary = data["secondary"]
    @partner = data["is_partner"]
    @commander = data["commander"]
    @brawler = data["brawler"]
    @specialized = data["specialized"]
    @specializes = data["specializes"]
    @spellbook = data["spellbook"]
    @in_spellbook = data["in_spellbook"]
    if data["foreign_names"]
      @foreign_names = data["foreign_names"].map{|k,v| [k.to_sym,v]}.to_h
      raise "Foreign data with empty value for #{name}" if @foreign_names.any?{|k,v| v.empty?}
    else
      @foreign_names = {}
    end
    @foreign_names_normalized = {}
    @foreign_names.each do |lang, names|
      @foreign_names_normalized[lang] = names.map{|n| hard_normalize(n)}
    end
    @related = data["related"]
    @typeline = [data["supertypes"], data["types"]].compact.flatten.join(" ")
    if data["subtypes"]
      @typeline += " - #{data["subtypes"].join(" ")}"
    end
    @typeline = -@typeline
    if data["keywords"]
      @keywords = data["keywords"].map{|k| -k}
    end
    @defense = data["defense"]
    calculate_mana_hash
    calculate_color_indicator
    calculate_reminder_text
    @front = (!@secondary or @layout == "aftermath" or @layout == "flip" or @layout == "adventure")
  end

  def partner?
    !!@partner
  end

  def front?
    @front
  end

  def back?
    !front?
  end

  def primary?
    !@secondary
  end

  def secondary?
    @secondary
  end

  def custom?
    # a card is custom if it has been printed in at least one custom set (to exclude uncards)...
    return false unless printings.any? { |printing| printing.set.custom? }
    # ...and hasn't been printed in an official black-border set (to exclude custom reprints of official cards)
    printings.all? { |printing| printing.set.custom? or printing.set.funny? }
  end

  def has_multiple_parts?
    !!@names
  end

  def inspect
    "Card(#{name})"
  end

  include Comparable
  def <=>(other)
    name <=> other.name
  end

  def to_s
    inspect
  end

  def legality_information(date=nil)
    LegalityInformation.new(self, date)
  end

  def first_release_date
    @first_release_date ||= @printings.map(&:release_date).compact.min
  end

  # If a card has non-promo printing, pick oldest, ignore promos
  # If a card has only promo printings, pick oldest
  # This deals with prerelease promos and similar
  #
  # Promos released at same time or earlier than the first release date
  # are not considered reprints
  def first_regular_release_date
    @first_regular_release_date ||= begin
      promo_printings, regular_printings = printings.partition{|cp| cp.set.types.include?("promo")}
      regular_printings.map(&:release_date).min || promo_printings.map(&:release_date).min
    end
  end

  def last_release_date
    @last_release_date ||= @printings.map(&:release_date).compact.max
  end

  def allowed_in_any_number?
    @types.include?("basic") or (
      @text and @text.include?("A deck can have any number of cards named")
    )
  end

  def commander?
    !!@commander
  end

  def brawler?
    !!@brawler
  end

  def count_prints
    @count_prints ||= printings.size
  end

  def count_paperprints
    @count_paperprints ||= printings.count(&:paper?)
  end

  def count_sets
    @count_sets ||= printings.map(&:set).uniq.size
  end

  def count_papersets
    @count_papersets ||= printings.select(&:paper?).map(&:set).uniq.size
  end

  def name_slug
    name
      .normalize_accents
      .gsub("'s", "s")
      .gsub("I'm", "Im")
      .gsub("You're", "Youre")
      .gsub("R&D", "RnD")
      .gsub(/[^a-zA-Z0-9\-]+/, "-")
      .gsub(/(\A-)|(-\z)/, "")
  end

  private

  def calculate_mana_hash
    if @mana_cost.nil?
      @mana_hash = nil
      return
    end
    @mana_hash = Hash.new(0)

    mana = @mana_cost.gsub(/\{(.*?)\}/) do
      m = $1
      case m
      when /\A\d+\z/
        @mana_hash["?"] += m.to_i
      when /\A[wubrgxyzcs]\z/
        # x is basically a color for this kind of queries
        @mana_hash[m] += 1
      when /\Ah([wubrg])\z/
        @mana_hash[$1] += 0.5
      when /\A([wubrg])\/([wubrg])\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\A([wubrg])\/p\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\A2\/([wubrg])\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      when /\A([wubrg])\/([wubrg])\/p\z/
        @mana_hash[normalize_mana_symbol(m)] += 1
      else
        raise "Unrecognized mana type: #{m}"
      end
      ""
    end
    raise "Mana query parse error: #{mana}" unless mana.empty?
  end

  def normalize_mana_symbol(sym)
    -sym.downcase.tr("/{}", "").chars.sort.join
  end

  def hard_normalize(s)
    -s.unicode_normalize(:nfd).gsub(/\p{Mn}/, "").downcase
  end

  def smart_convert_powtou(val)
    return val unless val.is_a?(String)
    # Treat augment "+1"/"-1" strings as regular 1/-1 numbers for search engine
    # The view can use special format for them
    return val.to_i if val =~ /\A\+\d+\z/
    if val !~ /\A-?[\d.]+\z/
      # It just so happens that "2+*" > "1+*" > "*" asciibetically
      # so we don't do any extra conversions,
      # but we might need to setup some eventually
      #
      # Including uncards
      # "*" < "*²" < "1+*" < "2+*"
      # but let's not get anywhere near that
      case val
      when "*", "*²", "1+*", "2+*", "7-*", "X", "∞", "?", "1d4+1"
        val
      when "*+1"
        "1+*"
      else
        raise "Unrecognized value #{val.inspect}"
      end
    elsif val.to_i == val.to_f
      val.to_i
    else
      val.to_f
    end
  end

  def calculate_color_indicator
    colors_inferred_from_mana_cost = (@mana_hash || {}).keys
      .flat_map do |x|
        next [] if x =~ /[?xyzcs]/
        x = x.sub(/[p2]/, "")
        if x =~ /\A[wubrg]+\z/
          x.chars
        else
          raise "Unknown mana cost: #{x}"
        end
      end
      .uniq

    actual_colors = @colors.chars

    if colors_inferred_from_mana_cost.sort == actual_colors.sort
      @color_indicator = nil
    else
      @color_indicator = Color.color_indicator_name(actual_colors)
    end
    if @color_indicator
      @color_indicator_set = actual_colors.to_set
    end
  end

  def calculate_reminder_text
    @reminder_text = nil
    basic_land_types = (["forest", "island", "mountain", "plains", "swamp"] & @types.to_a)
      .sort.join(" ")
    if not basic_land_types.empty?
      # Listing them all explicitly due to wubrg wheel order
      mana = case basic_land_types
      when "plains"
        "{W}"
      when "island"
        "{U}"
      when "swamp"
        "{B}"
      when "mountain"
        "{R}"
      when "forest"
        "{G}"
      when "island plains"
        "{W} or {U}"
      when "plains swamp"
        "{W} or {B}"
      when "island swamp"
        "{U} or {B}"
      when "island mountain"
        "{U} or {R}"
      when "mountain swamp"
        "{B} or {R}"
      when "forest swamp"
        "{B} or {G}"
      when "forest mountain"
        "{R} or {G}"
      when "mountain plains"
        "{R} or {W}"
      when "forest plains"
        "{G} or {W}"
      when "forest island"
        "{G} or {U}"
      when "forest plains swamp"
        "{W}, {B}, or {G}"
      when "forest island mountain"
        "{G}, {U}, or {R}"
      when "island mountain plains"
        "{U}, {R}, or {W}"
      when "mountain plains swamp"
        "{R}, {W}, or {B}"
      when "forest island swamp"
        "{B}, {G}, or {U}"
      when "forest mountain plains"
        "{R}, {G}, or {W}"
      when "island plains swamp"
        "{W}, {U}, or {B}"
      when "forest island plains"
        "{G}, {W}, or {U}"
      when "island mountain swamp"
        "{U}, {B}, or {R}"
      when "forest mountain swamp"
        "{B}, {R}, or {G}"
      else
        raise "No idea what's correct line for #{basic_land_types.inspect}"
      end
      @reminder_text = "({T}: Add #{mana}.)"
    elsif layout == "flip" and secondary?
      # Awkward wording
      other_name = (@names - [@name])[0]
      @reminder_text = "(#{@name} keeps color and mana cost of #{other_name} when flipped)"
    end
  end
end
