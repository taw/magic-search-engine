require "rails_helper"

RSpec.describe FormatController, type: :controller do
  render_views

  it "index" do
    get "index"
    assert_response 200
    assert_select %Q[a:contains("Commander")]
    assert_select %Q[a:contains("Modern")]
    assert_select %Q[a:contains("Shards of Alara Block")]
  end

  it "show - fake format" do
    get "show", params: { id: "return-to-homelands-block" }
    assert_response 404
  end

  it "show - Scars of Mirrodin Block" do
    get "show", params: { id: "scars-of-mirrodin-block" }
    assert_response 200
    assert_select %Q[title:contains("Scars of Mirrodin Block")]
    assert_select %Q[h3:contains("Scars of Mirrodin Block")]
    assert_select %Q[a:contains("Scars of Mirrodin")]
    assert_select %Q[a:contains("Mirrodin Besieged")]
    assert_select %Q[a:contains("New Phyrexia")]
    assert_select %Q[p:contains("There are no banned cards.")]
    assert_select %Q[p:contains("There are no restricted cards.")]
  end

  it "show - Innistrad Block" do
    get "show", params: { id: "innistrad-block" }
    assert_response 200
    assert_select %Q[title:contains("Innistrad Block")]
    assert_select %Q[h3:contains("Innistrad Block")]
    assert_select %Q[a:contains("Innistrad")]
    assert_select %Q[a:contains("Dark Ascension")]
    assert_select %Q[a:contains("Avacyn Restored")]
    assert_select %Q[a:contains("Lingering Souls")]
    assert_select %Q[p:contains("There are no restricted cards.")]
  end

  Format.all_format_classes.each do |format_class|
    format = format_class.new
    it "format - #{format}" do
      get "show", params: { id: format.format_pretty_name.parameterize }
      assert_response 200
    end
  end
end
