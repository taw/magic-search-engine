class PackController < ApplicationController
  def index
    @booster_types = $CardDatabase.supported_booster_types
    @title = "Packs"
  end
end
