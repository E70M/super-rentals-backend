require 'rails_helper'

api_headers = {
 	"Content-Type" => "application/vnd.api+json"
}

# Faker data is inserted via FactoryBot
post_data = {
	"data": {
    	"type": "rentals",
    	"attributes": {}
  	}
}

patch_data = {
 	"data": {
      "id": nil,
    	"type": "rentals",
    	"attributes": {
      		"city": ""
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
      # Seed req data
      rental = FactoryBot.build(:rental)
      req = post_data.deep_dup
      req[:data][:attributes] = attributes_for(:rental)
      # POST new rental
      post "/rentals", { params: req.to_json, headers: api_headers }
      expect(response).to have_http_status(:success)
    end
    it "increases rental count by 1" do
      # GET all available rentals, find count
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      comp_size = res_hash[:data].count + 1
      # Seed req data
      rental = FactoryBot.build(:rental)
      req = post_data.deep_dup
      req[:data][:attributes] = attributes_for(:rental)
      # POST new rental
      post "/rentals", { params: req.to_json, headers: api_headers }
      # GET all available rentals, check count has increased by 1
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(res_hash[:data].count).to eq(comp_size)
    end
    it "does not create duplicate rental" do
      # Seed req data
      rental = FactoryBot.build(:rental)
      req = post_data.deep_dup
      req[:data][:attributes] = attributes_for(:rental)
      # POST rental
      post "/rentals", { params: req.to_json, headers: api_headers }
      # POST same rental - expected to return error
      post "/rentals", { params: req.to_json, headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash[:errors][0][:title]).to eq("has already been taken")
    end
    it "does not create rental with missing information" do
      post "/rentals", { params: post_data.to_json, headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  expect(res_hash[:errors][0][:title]).to eq("can't be blank")
    end
  end

  describe 'GET #show' do
  	it "returns rental" do
      # Seed req data
  	  rental = FactoryBot.build(:rental)
      req = post_data.deep_dup
      req[:data][:attributes] = attributes_for(:rental)
      # POST rental
  	  post "/rentals", { params: req.to_json, headers: api_headers }
  	  # GET all available rentals, select top record for unit id
  	  get "/rentals", { headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  unit_id = res_hash[:data][0][:id]
  	  get_path = "/rentals/" + unit_id
  	  # GET rental with unit id
      get get_path, { headers: api_headers }
  	  expect(response).to have_http_status(:success)
  	end
  end

  describe 'PATCH #update' do
    before {
      # Seed req data
      rental = FactoryBot.build(:rental)
      req = post_data.deep_dup
      req[:data][:attributes] = attributes_for(:rental)
      post "/rentals", { params: req.to_json, headers: api_headers }
      get "/rentals", { headers: api_headers }
    }
  	it "updates rental" do
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
  	  unit_id = res_hash[:data][0][:id]
      # Seed req data
      req = patch_data.deep_dup
      req[:data][:id] = unit_id
      req[:data][:attributes][:city] = Faker::Address.city
  	  # PATCH rental with unit id, change city name
  	  patch_path = "/rentals/" + unit_id
  	  patch patch_path, { params: req.to_json, headers: api_headers }
  	  res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(response).to have_http_status(:success)
  	end
    it "does not change rental count" do
      res_hash = JSON.parse(response.body, symbolize_names: true)
      unit_id = res_hash[:data][0][:id]
      comp_size = res_hash[:data].count
      # Seed req data
      req = patch_data.deep_dup
      req[:data][:id] = unit_id
      req[:data][:attributes][:city] = Faker::Address.city
      # PATCH rental with unit id, change city name
      patch_path = "/rentals/" + unit_id
      patch patch_path, { params: req.to_json, headers: api_headers }
      # GET all available rentals, check count has not changed
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(res_hash[:data].count).to eq(comp_size)
    end
  end

  describe 'DELETE #destroy' do
    before {
      # Seed req data
      rental = FactoryBot.build(:rental)
      req = post_data.deep_dup
      req[:data][:attributes] = attributes_for(:rental)
      post "/rentals", { params: req.to_json, headers: api_headers }
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