require 'rails_helper'

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

incomplete_post_data = {
	"data": {
    	"type": "rentals",
    	"attributes": {
      		"title": "Grand Old Mansion",
      		"owner": "Veruca Salt",
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

RSpec.describe "Rentals" do
  describe 'GET #index' do
  	it "returns empty rental list" do
  	  get "/rentals", { headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash[:data].count).to eq(0)
  	end
  end

  describe 'POST #create' do
    it "creates rental" do
      post "/rentals", { params: post_data.to_json, headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash).to eq(expected_res)
    end
    it "increases rental count by 1" do
      # GET all available rentals, find count
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      comp_size = res_hash[:data].count + 1
      # POST new rental, check correct rental has been created
      post "/rentals", { params: post_data.to_json, headers: api_headers }
      # GET all available rentals, check count has increased by 1
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(res_hash[:data].count).to eq(comp_size)
    end
    it "does not create duplicate rental" do
      # Seed data
      post "/rentals", { params: post_data.to_json, headers: api_headers }
      # POST same rental - expected to return error
      post "/rentals", { params: post_data.to_json, headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash[:errors][0][:title]).to eq("has already been taken")
    end
    it "does not create rental with missing information" do
      post "/rentals", { params: incomplete_post_data.to_json, headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash[:errors][0][:title]).to eq("can't be blank")
    end
  end

  describe 'GET #show' do
  	it "returns rental" do
  	  # Seed data
  	  post "/rentals", { params: post_data.to_json, headers: api_headers }
  	  # GET all available rentals, select top record for unit id
  	  get "/rentals", { headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  unit_id = res_hash[:data][0][:id]
  	  get_path = "/rentals/" + unit_id
  	  # GET rental with unit id
      get get_path, { headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash).to eq(expected_res)
  	end
  end

  describe 'PATCH #update' do
    before {
      post "/rentals", { params: post_data.to_json, headers: api_headers }
      get "/rentals", { headers: api_headers }
    }
  	it "updates rental" do
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  unit_id = res_hash[:data][0][:id]
  	  # PATCH rental with unit id, change city name
  	  patch_path = "/rentals/" + unit_id
  	  patch patch_path, { params: patch_data.to_json, headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash).to eq(expected_patch_res)
  	end
    it "does not change rental count" do
      res_hash = JSON.parse(response.body, symbolize_names: true)
      unit_id = res_hash[:data][0][:id]
      comp_size = res_hash[:data].count
      # PATCH rental with unit id, change city name
      patch_path = "/rentals/" + unit_id
      patch patch_path, { params: patch_data.to_json, headers: api_headers }
      # GET all available rentals, check count has not changed
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(res_hash[:data].count).to eq(comp_size)
    end
  end

  describe 'DELETE #destroy' do
    before {
      post "/rentals", { params: post_data.to_json, headers: api_headers }
      get "/rentals", { headers: api_headers }
    }
    it "deletes rental" do
      res_hash = JSON.parse(response.body, symbolize_names: true)
      unit_id = res_hash[:data][0][:id]
  	  del_path = "/rentals/" + unit_id
      delete del_path, { headers: api_headers }
  	  # GET rental with unit id, check it has been deleted
  	  get del_path, { headers: api_headers }
  	  expect(response).to have_http_status(:missing)
    end
    it "decreases rental count by 1" do
      res_hash = JSON.parse(response.body, symbolize_names: true)
      unit_id = res_hash[:data][0][:id]
      comp_size = res_hash[:data].count - 1
      del_path = "/rentals/" + unit_id
      delete del_path, { headers: api_headers }
      # GET all available rentals, check collection size has decreased by 1
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(res_hash[:data].count).to eq(comp_size)
    end
    it "does not delete a non-existent record" do
      res_hash = JSON.parse(response.body, symbolize_names: true)
      unit_id = res_hash[:data][0][:id]
      del_path = "/rentals/" + unit_id
      delete del_path, { headers: api_headers }
      # DELETE same rental - expect to return error
      delete del_path, { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(res_hash[:errors][0][:title]).to eq("Record not found")
    end
  end
end