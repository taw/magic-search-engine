require "rails_helper"

# Controller specs synthesize the url from the route, so they can't tell
# /card?page=2 from /page/2/card - which is exactly what these check
RSpec.describe "card routing", type: :request do
  it "serves the search page at the root" do
    get "/", params: {q: "Karn Liberated"}
    expect(response).to have_http_status(200)
    expect(response.body).to include("Karn Liberated")
  end

  # One page of results, one url - "?page=2" is redirected to the pretty one
  it "redirects a paginated search to its own url" do
    get "/card", params: {q: "e:nph", page: "2"}
    expect(response).to redirect_to("/page/2/card?q=e%3Anph")
  end

  it "does not redirect an unpaginated search" do
    get "/card", params: {q: "e:nph"}
    expect(response).to have_http_status(200)
  end

  it "serves the paginated url itself" do
    get "/page/2/card", params: {q: "e:nph"}
    expect(response).to have_http_status(200)
  end

  # Crawlers walking every page of every search were most of the load on a
  # small server, and none of it was anyone reading the site
  describe "crawlers" do
    ["MJ12bot", "PetalBot", "Bytespider"].each do |bot|
      it "turns #{bot} away from paginated searches" do
        get "/page/2/card", params: {q: "e:nph"}, headers: {"HTTP_USER_AGENT" => bot}
        expect(response).to have_http_status(403)
      end
    end

    it "lets them read the first page" do
      get "/card", params: {q: "e:nph"}, headers: {"HTTP_USER_AGENT" => "PetalBot"}
      expect(response).to have_http_status(200)
    end

    it "lets everyone else paginate" do
      get "/page/2/card", params: {q: "e:nph"}, headers: {"HTTP_USER_AGENT" => "Mozilla/5.0"}
      expect(response).to have_http_status(200)
    end
  end

  it "serves a card with and without its name in the url" do
    get "/card/nph/1"
    expect(response).to have_http_status(200)
    get "/card/nph/1/Karn-Liberated"
    expect(response).to have_http_status(200)
  end

  # ★ and friends in collector numbers have to survive the round trip
  it "serves a card whose collector number needs escaping" do
    get "/card/oarc/8%E2%98%85"
    expect(response).to have_http_status(200)
    expect(response.body).to include("A Display of My Dark Power")
  end
end
