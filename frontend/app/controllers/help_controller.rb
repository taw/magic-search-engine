class HelpController < ApplicationController
  def syntax
    @title = "Syntax"
  end

  def rules
    @title = "Custom Magic Comprehensive Rules"
  end

  def contact
    @title = "Contact"
  end
end
