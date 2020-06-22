require 'rails_helper'
require 'json'
require 'database_cleaner/active_record'

api_headers = {
 	"Content-Type" => "application/vnd.api+json"
}

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

patch_data = {
 	"data": {
    	"type": "rentals",
    	"id": 1,
    	"attributes": {
      		"city": "San Diego"
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

expected_patch_res = {
    "data": {
        "id": "1",
        "type": "rentals",
        "links": {
            "self": "http://www.example.com/rentals/1"
        },
        "attributes": {
            "title": "Grand Old Mansion",
            "owner": "Veruca Salt",
            "city": "San Diego",
            "category": "Estate",
            "image": "https://upload.wikimedia.org/wikipedia/commons/c/cb/Crane_estate_(5).jpg",
            "bedrooms": 15,
            "description": "This grand old mansion sits on over 100 acres of rolling hills and dense redwood forests."
        }
    }
}

RSpec.describe "Rentals", type: :request do
  describe 'GET #index' do
  	it "returns empty rental list" do
  	  get "/rentals", { headers: api_headers }
  	  expect(response).to have_http_status(:success)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash[:data].count).to eq(0)
  	end
  end

  describe 'POST #create' do
    it "creates rental" do
      # GET all available rentals, find collection size
      get "/rentals", { headers: api_headers }
      expect(response).to have_http_status(:success)
      res_hash = JSON.parse(response.body, symbolize_names: true)
      puts res_hash
      # POST new rental, check correct rental has been created
      comp_size = res_hash[:data].count + 1
      post "/rentals", { params: post_data.to_json, headers: api_headers }
      expect(response).to have_http_status(:success)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash).to eq(expected_res)
  	  # GET all available rentals, check collection size has increased by 1
  	  get "/rentals", { headers: api_headers }
  	  expect(response).to have_http_status(:success)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash[:data].count).to eq(comp_size)
    end
    it "does not create duplicate rental" do
      post "/rentals", { params: post_data.to_json, headers: api_headers }
      expect(response).not_to have_http_status(:success)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash[:errors][0][:title]).to eq("has already been taken")
    end
  end

  describe 'GET #show' do
  	it "returns rental" do
  	  # GET all available rentals, select top record for unit id
  	  get "/rentals", { headers: api_headers }
      expect(response).to have_http_status(:success)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  unit_id = res_hash[:data][0][:id]
  	  get_path = "/rentals/" + unit_id
  	  # GET rental with unit id
      get get_path, { headers: api_headers }
  	  expect(response).to have_http_status(:success)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  # p res_hash.keys.first.class
  	  expect(res_hash).to eq(expected_res) # TODO: db cleaner (this line will fail if db does not reset before tests)
  	end
  end

  describe 'PATCH #update' do
  	it "updates rental" do
  	  # GET all available rentals, select top record for unit id
      get "/rentals", { headers: api_headers }
      expect(response).to have_http_status(:success)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  unit_id = res_hash[:data][0][:id]
  	  # PATCH rental with unit id, change city name
  	  patch_path = "/rentals/" + unit_id
  	  patch patch_path, { params: patch_data.to_json, headers: api_headers }
  	  expect(response).to have_http_status(:success)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash).to eq(expected_patch_res)
  	end
  end

  describe 'DELETE #destroy' do
    it "deletes rental" do
      # GET all available rentals, select top record for unit id
      get "/rentals"
      expect(response).to have_http_status(:success)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  unit_id = res_hash[:data][0][:id]
  	  # DELETE rental with unit id
  	  comp_size = res_hash[:data].count - 1
  	  del_path = "/rentals/" + unit_id
      delete del_path, { headers: api_headers }
      expect(response).to have_http_status(:success)
  	  # GET all available rentals, check collection size has decreased by 1
  	  get "/rentals", { headers: api_headers }
  	  expect(response).to have_http_status(:success)
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash[:data].count).to eq(comp_size)
  	  # GET rental with unit id, check it has been deleted
  	  get del_path, { headers: api_headers }
  	  expect(response).to have_http_status(:missing)
    end
  end
end