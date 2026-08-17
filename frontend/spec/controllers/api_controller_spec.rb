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

  it "returns the card's details" do
    get "show", params: {set: "nph", id: "1"}
    assert_response 200
    expect(json_response).to include(
      "name" => "Karn Liberated",
      "mana_cost" => "{7}",
      "typeline" => "Legendary Planeswalker - Karn",
      "power" => nil,
      "toughness" => nil,
      "loyalty" => 6,
      "card_path" => "/card/nph/1/Karn-Liberated",
    )
    expect(json_response["text"]).to start_with("[+4]: Target player exiles a card from their hand.")
  end

  it "passes query warnings on" do
    get "search", params: {q: "is:foobar"}
    assert_response 200
    expect(json_response["warnings"]).to eq(["Unrecognized token: is:foobar"])
  end

  it "has no warnings for a query it understood" do
    get "search", params: {q: "Karn Liberated"}
    assert_response 200
    expect(json_response["warnings"]).to eq([])
  end

  # One entry per card, not per printing
  it "returns one printing per card" do
    get "search", params: {q: "e:nph,mm2,uma !Karn Liberated"}
    assert_response 200
    expect(json_response["total"]).to eq(1)
    expect(json_response["cards"].map{|c| c["card_path"]}).to eq(["/card/nph/1/Karn-Liberated"])
  end
end
