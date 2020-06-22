require 'rails_helper'
require 'json'

post_data = {
  "data": {
    "type": "rentals",
    "attributes": {
      "title": "Grand Old Mansion",
      "owner": "Veruca Salt",
      "city": "San Francisco",
      "category": "Estate",
      "image": "https://upload.wikimedia.org/wikipedia/commons/c/cb/Crane_estate_(5).jpg",
      "bedrooms": 15,
      "description": "This grand old mansion sits on over 100 acres of rolling hills and dense redwood forests."
    }
  }
}

expected_res = {
    "data": {
        "id": "1",
        "type": "rentals",
        "links": {
            "self": "http://www.example.com/rentals/1"
        },
        "attributes": {
            "title": "Grand Old Mansion",
            "owner": "Veruca Salt",
            "city": "San Francisco",
            "category": "Estate",
            "image": "https://upload.wikimedia.org/wikipedia/commons/c/cb/Crane_estate_(5).jpg",
            "bedrooms": 15,
            "description": "This grand old mansion sits on over 100 acres of rolling hills and dense redwood forests."
        }
    }
}

RSpec.describe "Rentals", type: :request do
  describe '#index' do
  	it "returns every available rental" do
  	  get "/rentals"
  	  expect(response).to have_http_status(200)
  	  expect(response["data"])
  	end
  end

  describe '#show' do
  	it "returns Grand Old Mansion rental" do
      api_headers = { "Content-Type" => "application/vnd.api+json" }
      # POST rental record
      post "/rentals", { params: post_data.to_json, headers: api_headers }
      puts response.body
      # GET rental record from db
      get "/rentals/1", { headers: api_headers }
  	  expect(response).to have_http_status(200)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  puts expect(res_hash).to eq(expected_res)
  	end
  end
end