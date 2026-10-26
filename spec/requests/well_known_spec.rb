require "rails_helper"

RSpec.describe "Well-known files", type: :request do
  it "serves the apple-app-site-association as JSON" do
    get "/.well-known/apple-app-site-association"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/json")
    details = response.parsed_body.dig("applinks", "details", 0)
    expect(details["appIDs"]).to eq([ "QHJAD8Z2WL.gizz.tapes.GizzTapes" ])
  end

  it "serves assetlinks.json as JSON" do
    get "/.well-known/assetlinks.json"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/json")
    package_names = response.parsed_body.map { |statement| statement.dig("target", "package_name") }
    expect(package_names).to eq([ "gizz.tapes.full", "gizz.tapes.foss" ])
  end
end
