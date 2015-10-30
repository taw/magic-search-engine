class SetController < ApplicationController
  def show
    id = params[:id]
    @set = $CardDatabase.sets[id]
    render_404 unless @set
  end
end
