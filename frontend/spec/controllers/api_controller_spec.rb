require "rails_helper"

RSpec.describe ApiController, type: :controller do
  def json_response
    JSON.parse(response.body)
  end

  it "show card" do
    get "show", params: {set: "nph", id: "1"}
    assert_response 200
    expect(json_response["name"]).to eq("Karn Liberated")
    expect(json_response["card_path"]).to be_present
  end

  it "bad set" do
    get "show", params: {set: "lolwtf", id: "1"}
    assert_response 404
    expect(json_response["error"]).to eq("Not found")
  end

  it "bad collector number" do
    get "show", params: {set: "nph", id: "1000"}
    assert_response 404
    expect(json_response["error"]).to eq("Not found")
  end

  it "search nothing" do
    get "search"
    assert_response 200
    expect(json_response["total"]).to eq(0)
    expect(json_response["cards"]).to eq([])
  end

  it "search something" do
    get "search", params: {q: "Karn Liberated"}
    assert_response 200
    expect(json_response["total"]).to eq(1)
    expect(json_response["cards"].map{|c| c["name"]}).to eq(["Karn Liberated"])
  end

  it "search nothing found" do
    get "search", params: {q: "italian spiderman"}
    assert_response 200
    expect(json_response["total"]).to eq(0)
  end

  it "search paginated" do
    get "search", params: {q: "t:planeswalker", page: "2"}
    assert_response 200
    expect(json_response["cards"].size).to eq(10)
  end
end
