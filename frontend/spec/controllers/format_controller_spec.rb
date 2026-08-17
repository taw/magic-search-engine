require "rails_helper"

RSpec.describe FormatController, type: :controller do
  render_views

  it "index" do
    get "index"
    assert_response 200
    assert_select %[a:contains("Commander")]
    assert_select %[a:contains("Modern")]
    assert_select %[a:contains("Shards of Alara Block")]
  end

  it "show - fake format" do
    get "show", params: {id: "return-to-homelands-block"}
    assert_response 404
  end

  it "show - Scars of Mirrodin Block" do
    get "show", params: {id: "scars-of-mirrodin-block"}
    assert_response 200
    assert_select %[title:contains("Scars of Mirrodin Block")]
    assert_select %[h3:contains("Scars of Mirrodin Block")]
    assert_select %[a:contains("Scars of Mirrodin")]
    assert_select %[a:contains("Mirrodin Besieged")]
    assert_select %[a:contains("New Phyrexia")]
    assert_select %[p:contains("There are no banned cards.")]
    assert_select %[p:contains("There are no restricted cards.")]
  end

  it "show - Innistrad Block" do
    get "show", params: {id: "innistrad-block"}
    assert_response 200
    assert_select %[title:contains("Innistrad Block")]
    assert_select %[h3:contains("Innistrad Block")]
    assert_select %[a:contains("Innistrad")]
    assert_select %[a:contains("Dark Ascension")]
    assert_select %[a:contains("Avacyn Restored")]
    assert_select %[a:contains("Lingering Souls")]
    assert_select %[p:contains("There are no restricted cards.")]
  end

  # These two moved on the Standard banlist in 2011 and never came back
  it "show - ban history" do
    get "show", params: {id: "standard"}
    assert_response 200
    assert_select %[h4:contains("Ban history")]
    assert_select %[h6:contains("2011-07-01")]
    assert_select %[li a[href="/card?q=%21Jace%2C+the+Mind+Sculptor"]]
    assert_select %[a:contains("Announcement")]
    events = css_select("li").map{|li| li.text.split(/\s+/).join(" ").strip}
    assert_includes events, "Jace, the Mind Sculptor: legal → banned"
    assert_includes events, "Stoneforge Mystic: legal → banned"
  end

  it "show - rotation history" do
    get "show", params: {id: "standard"}
    assert_response 200
    assert_select %[h4:contains("Rotation history")]
    assert_select %[li:contains("Currently:")]
    assert_select %[li:contains("Until 2011-09-30:")] do |items|
      assert_includes items.first.text, "Scars of Mirrodin"
    end
  end

  it "show - restricted cards" do
    get "show", params: {id: "vintage"}
    assert_response 200
    assert_select %[h4:contains("Restricted cards")]
    assert_select %[li a:contains("Black Lotus")]
  end

  Format.all_format_classes.each do |format_class|
    format = format_class.new
    it "format - #{format}" do
      get "show", params: {id: format.format_pretty_name.parameterize}
      assert_response 200
    end
  end
end
