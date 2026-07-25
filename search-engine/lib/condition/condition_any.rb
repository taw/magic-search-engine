class ConditionAny < ConditionOr
  attr_reader :query

  def initialize(query)
    @query = query.downcase
    @conds = [
      ConditionWord.new(query),
      ConditionArtist.new(query),
      ConditionFlavor.new(query),
      ConditionOracle.new(query),
      ConditionTypes.new(query),
      ConditionForeign.new("foreign", query),
    ]
    case @query
    when "white"
      @conds << ConditionColorExpr.new("c", ">=", "w")
    when "blue"
      @conds << ConditionColorExpr.new("c", ">=", "u")
    when "black"
      @conds << ConditionColorExpr.new("c", ">=", "b")
    when "red"
      @conds << ConditionColorExpr.new("c", ">=", "r")
    when "green"
      @conds << ConditionColorExpr.new("c", ">=", "g")
    when "colorless"
      @conds << ConditionColorExpr.new("c", "=", "")
    when "common", "uncommon", "rare", "mythic", "mythic rare", "special", "basic"
      @conds << ConditionRarity.new("=", @query)
    # Same value syntax as pow=/tou= accepts, so weird ones like Tarmogoyf's */1+* work too
    when %r[\A([²\d\.\-\*\+½x∞\?]+)/([²\d\.\-\*\+½x∞\?]+)\z]
      @conds << ConditionAnd.new(
        ConditionExpr.new("pow", "=", $1),
        ConditionExpr.new("tou", "=", $2),
      )
    when "augment"
      @conds << ConditionIsAugment.new
    when "battleland", "tangoland"
      @conds << ConditionIsBattleland.new
    when "bounceland", "karoo"
      @conds << ConditionIsBounceland.new
    when "canopyland", "canland"
      @conds << ConditionIsCanopyland.new
    when "checkland"
      @conds << ConditionIsCheckland.new
    when "colorshifted"
      @conds << ConditionFrameEffect.new("colorshifted")
    when "commander" # ???
      @conds << ConditionIsCommander.new
    when "digital"
      @conds << ConditionIsDigital.new
    when "dual"
      @conds << ConditionIsDual.new
    when "draft"
      @conds << ConditionIsDraft.new
    when "fastland"
      @conds << ConditionIsFastland.new
    when "fetchland"
      @conds << ConditionIsFetchland.new
    when "filterland"
      @conds << ConditionIsFilterland.new
    when "funny"
      @conds << ConditionIsFunny.new
    when "gainland"
      @conds << ConditionIsGainland.new
    when "gamechanger"
      @conds << ConditionIsGamechanger.new
    when "keywordsoup"
      @conds << ConditionIsKeywordsoup.new
    when "manland", "creatureland"
      @conds << ConditionIsManland.new
    when "meldpart"
      @conds << ConditionIsMeldpart.new
    when "meldresult"
      @conds << ConditionIsMeldresult.new
    when "multipart"
      @conds << ConditionIsMultipart.new
    when "outlaw"
      @conds << ConditionIsOutlaw.new
    when "painland"
      @conds << ConditionIsPainland.new
    when "pathway"
      @conds << ConditionIsPathway.new
    when "party"
      @conds << ConditionIsParty.new
    when "permanent"
      @conds << ConditionIsPermanent.new
    when "primary"
      @conds << ConditionIsPrimary.new
    when "secondary"
      @conds << ConditionIsSecondary.new
    when "shadowland", "snarl"
      @conds << ConditionIsShadowland.new
    when "storageland"
      @conds << ConditionIsStorageland.new
    when "triland"
      @conds << ConditionIsTriland.new
    when "front"
      @conds << ConditionIsFront.new
    when "back"
      @conds << ConditionIsBack.new
    when "booster"
      @conds << ConditionIsBooster.new
    when "promo"
      @conds << ConditionSetType.new("promo")
    when "reprint"
      @conds << ConditionIsReprint.new
    when "reserved"
      @conds << ConditionIsReserved.new
    when "scryland"
      @conds << ConditionIsScryland.new
    when "shockland"
      @conds << ConditionIsShockland.new
    when "spell"
      @conds << ConditionIsSpell.new
    when "timeshifted"
      @conds << ConditionIsTimeshifted.new
    when "unique"
      @conds << ConditionIsUnique.new
    when "vanilla"
      @conds << ConditionIsVanilla.new
    end
    setup_conds!
  end

  def to_s
    "any:#{maybe_quote(@query)}"
  end

  def ==(other)
    self.class == other.class and
      self.query == other.query
  end
end
