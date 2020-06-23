require 'rails_helper'

api_headers = { "Content-Type" => "application/vnd.api+json" }

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
      create(:rental)
      get "/rentals", { headers: api_headers }
      expect(response).to have_http_status(:success)
    end
    it "increases rental count by 1" do
      # GET all available rentals, find count
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      comp_size = res_hash[:data].count + 1
      create(:rental)
      # GET all available rentals, check count has increased by 1
      get "/rentals", { headers: api_headers }
      res_hash = JSON.parse(response.body, symbolize_names: true)
      expect(res_hash[:data].count).to eq(comp_size)
    end
    # it "does not create duplicate rental" do
    #   # GET all available rentals, find count
    #   get "/rentals", { headers: api_headers }
    #   res_hash = JSON.parse(response.body, symbolize_names: true)
    #   comp_size = res_hash[:data].count + 1
    #   create_list(:rental, 2)
    #   # GET all available rentals, check count has only increased by 1
    #   get "/rentals", { headers: api_headers }
    #   res_hash = JSON.parse(response.body, symbolize_names: true)
    #   puts res_hash
    #   expect(res_hash[:data].count).to eq(comp_size)
    # end
    # it "does not create rental with missing information" do
    #   # GET all available rentals, find count
    #   get "/rentals", { headers: api_headers }
    #   res_hash = JSON.parse(response.body, symbolize_names: true)
    #   comp_size = res_hash[:data].count
    #   create(:rental, title: "")
    #   puts response
    #   GET all available rentals, check count has not increased
    #   get "/rentals", { headers: api_headers }
    #   res_hash = JSON.parse(response.body, symbolize_names: true)
    #   expect(res_hash[:data].count).to eq(comp_size)
    # end
  end

  describe 'GET #show' do
    it "returns rental" do
      create(:rental)
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
    let!(:rental) { create(:rental) }
    before { get "/rentals", { headers: api_headers } }
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
    let!(:rental) { create(:rental) }
    before { get "/rentals", { headers: api_headers } }
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