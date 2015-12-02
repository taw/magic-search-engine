class HelpController < ApplicationController
  def syntax
    @title = "Syntax"
  end

  def rules
    @title = "Magic: The Gathering Comprehensive Rules"
  end

  def contact
    @title = "Contact"
  end
end
